---
layout: post
---
I've been looking for some new problems to work on in F# to get more
comfortable with the language.?? I've been rather slack of late because of
other projects but I had a little bit of time this week.?? I decided it would
be fun to join the crowd and play away at the problems on the [project
euler](http://projecteuler.net/) site.?? That being said, answer #1.

    
    
    module Euler =


        let problem1() =


            let test i = 


                match (0 = i % 3) || (0 = i % 5) with


                    | true -> Some i


                    | false -> None


            let targetSeq = Seq.choose test [0..999]


            Seq.sum targetSeq

