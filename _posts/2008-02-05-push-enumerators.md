---
layout: post
---
If you read Jon Skeet's blog you'll notice he's been playing around lately with "push" style enumerators.  Push enumerators are the concept of "we'll tell you when we're ready".  This is different from IEnumerator<T> which is more of a pull; "ask me if I have more data model".

His latest idea is an interface based approach called IDataProducer<T>.  The full post can be found here.  <http://msmvps.com/blogs/jon.skeet/archive/2007/11/29/group-pipelining-returns-new-and-improved-design.aspx>.

After reading the post I decided to try and bridge the gap between the worlds of Push/Pull models by defining an enumerator over an IDataProducer<T>.  Integration with the existing paradigms is extremely important for the adoption of a new technology.  Eventually you'll eventually want to pass your asynchronous enumerator off to an API requiring IEnumerable<T>.

Since we are implementing a pull model it will revolve around asking for more data and blocking until such data is available.  To implement the wait functionality I've used an AutoResetEvent to provide signaling between threads.  One of the tricky aspects is that IDataProducer<T> can live on any thread and hence any thread can be raising the various events.  

Below is my first attempt at getting it to work.  It has a couple of defects.

  1. I don't dispose of the AutoResetEvent.  Reason being that it's possible for a consumer of IEnumerable<T> to only consume part of the data.  If they only consume half of the data and then dispose of the EnumerableDataProducer and another event comes I'll be accessing a disposed WaitHandle.  You can work around this but I wanted to keep it simpler for now.
  2. It's not Reset-able.  The generated IEnumerator<T> throws a NotSupportedException anyway but we'd have to do a bit of work to make this resetable. 
    
    
``` csharp
public class EnumerableDataProducer<T> : IEnumerable<T>
{
    private object m_lock = new object();
    private bool m_finished;
    private AutoResetEvent m_event = new AutoResetEvent(false);
    private Queue<T> m_queue = new Queue<T>();

    public EnumerableDataProducer(IDataProducer<T> producer)
    {
        producer.DataProduced += new Action<T>(OnDataProdecuded);
        producer.EndOfData += new Action(OnEndOfData);
    }

    private void OnDataProdecuded(T obj)
    {
        lock (m_lock)
        {
            m_queue.Enqueue(obj);
        }

        m_event.Set();
    }

    private void OnEndOfData()
    {
        lock (m_lock)
        {
            m_finished = true;
        }
        m_event.Set();
    }

    #region IEnumerable<T> Members

    public IEnumerator<T> GetEnumerator()
    {
        while (true)
        {
            bool needWait = false;
            lock (m_lock)
            {
                if (m_finished)
                {
                    break;
                }

                if (m_queue.Count > 0)
                {
                    yield return m_queue.Dequeue();
                }
                else
                {
                    needWait = true;
                }
            }

            if (needWait)
            {
                m_event.WaitOne();
            }
        }
    }

    #endregion

    #region IEnumerable Members

    System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    #endregion
}
```

    

