---
layout: post
---
When developing an ASP.Net page I tend to pass a lot of data between pages.  A
lot of it comes from being fairly OO natured and wanting to have a page that
displays a particular type of content.

There are lots of articles detailing how to pass data between pages that have
a 1-1 relationship using the PreviousPage property and PreviousPageType
directive.  That is great for wizard style pages where there is only one page
that is allowed to pass data to a particular page.  However it's not as
helpful when the target page is meant to take input from multiple sources
because you can only specify a single PreviousPageType directive.

The approach I take is interface based.  The PreviousPage property is
available whether or not the PreviousPageType directive is present in the
page.  All the PreviousPageType directive does is make the property strongly
typed.  Without it the directive it's just typed as Page.  To make it strongly
typed, I create an interface that the calling page must implement and then
attempt to cast the source page into the specific interface.

    
    
    


    
    
    Partial Public Class _Default
    
    


    
    
      Inherits System.Web.UI.Page
    
    


    
    
      Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
    
    


    
    
        Dim source As ITextSource = TryCast(Me.PreviousPage, ITextSource)
    
    


    
    
        If source IsNot Nothing Then
    
    


    


    
    
          Display(source) 
    
    


    
    
        Else
    
    


    


    
    
          ...
    
    


    
    
        End If
    
    


    


    
    
      End Sub
    
    


    
    
    End Class
    
    


    
    
     
    
    


    
    
    Public Interface ITextSource
    
    


    
    
      ReadOnly Property Text() As String
    
    


    
    
    End Interface
    
    


    


    

This gives us all of the benefits of using the PreviousPageType directive with
just a few lines of overhead.  It makes passing data between pages trivial.

