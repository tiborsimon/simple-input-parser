# Simple Input Parser

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/tiborsimon/simple-input-parser-for-matlab?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Easy to use variable lenght input parser mechanism that provides a convenient way to enchance your custom function parameter handling.

## Detailed description 

Say you have a function with a lot of parameters. Some of them may be optional. In the old way, your users had to remember exactly how many parameters would your function need and they had to remember the exact order of the parameters as well.

Let's take a sine syntesizer function.
```
ssin(440, 2, 45, 48e3, 0.8)
```
Is this a user friendly function? I don't think so. Sadly lot of the functions work this way. The user has to look up the definition of the function or the provided help to understand what is happening there.

What if you could provide an on-line help for your users during reading and using your functions?

```
ssin('f', 440, 'A', 2, 'phi', 45, 'fs', 48e3, 'L', 0.8)
```
Much better and readable way to call a function. Evryone knows exactly what is happening here. But do you really need to force your users to remember your parameter order that is probably inconvienient for them? 

How about they can pass the parameters in any arbitrary order they want?

```
ssin('A', 2, 'f', 440, 'L', 0.8, 'fs', 48e3, 'phi', 45)
```

Okay, this function is really user friendly now. But do your users like to type a lot of commas and apostrophes? I don't think so. How about this function call?

```
ssin('A f L fs phi', 2, 440, 0.8, 48e3, 45)
```

With Simple Input Parser this is a valid input for a function! 

Well, this is much less character to type here, but I see spaces. Do you want to force your users to type spaces if they don't necessary want to? What if they can left the spaces?

```
ssin('AfLfsphi', 2, 440, 0.8, 48e3, 45)
```

Yes, this is the most compact form of a function call with Simple Input Parser. Do you think it is useful you? Don't hesitate to try it out.
