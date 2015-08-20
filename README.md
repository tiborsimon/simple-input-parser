# Simple Input Parser

Easy to use variable lenght input parser mechanism that provides a convenient and advanced way to enchance your custom function parameter handling.

The current version sports a _MATLAB_ implementation, but other language ports are coming too.

<a title="Latest version" href="https://github.com/tiborsimon/simple-input-parser/releases/latest" target="_blank">
   <img src="https://img.shields.io/badge/version-v1.4.0-green.svg?style=flat" />
</a>
<a title="Goto article" href="http://tiborsimon.github.io/programming/simple-input-parser/" target="_blank">
   <img src="https://img.shields.io/badge/article-read-blue.svg?style=flat" />
</a>
<a title="Goto discussion" href="http://tiborsimon.github.io/programming/simple-input-parser/#discussion" target="_blank">
   <img src="https://img.shields.io/badge/discussion-join-orange.svg?style=flat" />
</a>
<a title="License" href="#license">
   <img src="http://img.shields.io/badge/license-MIT-green.svg?style=flat" />
</a>

### Features

- Arbitrary parameter order
- Three mode of operation
   - Key value pair mode
   - Bulk mode
   - Flag mode
   - Extra flag mode
- Compact yet clear parameter passing
- Parameter validation by type
- Custom validator functions with custom error messages

## Installation

- Download the [latest release](https://github.com/tiborsimon/simple-input-parser/releases/latest).
- Run the `install.m` script inside the downloaded `simple-input-parser` folder.
- Done. Now you have __Simple Input Parser__ on your system.

_This installation method is powered by the <a href="http://tiborsimon.github.io/programming/matlab-library-system/" target="_blank" >MATLAB Library System</a>._

## Is this necessary for me?

Well, you decide..

#### Old way to call a function

Say you have a function with a lot of parameters. Some of them may be optional. In the old way, your users had to remember exactly how many parameters would your function need and they had to remember the exact order of the parameters as well.

Let's take a sine syntesizer function.
```
ssin(440, 2, 45, 48e3, 0.8)
```
Is this a user friendly function? I don't think so. This is a __horrible__ function.. Sadly lot of the functions work this way. The user has to look up the definition of the function or the provided help to understand what is happening there.

#### Simple Input Parser way

What if you could provide an on-line help for your users during reading and using your functions?

```
ssin('f', 440, 'A', 2, 'phi', 45, 'fs', 48e3, 'L', 0.8)
```
Much better and readable way to call a function. Everyone knows exactly what is happening. 

But do you really need to force your users to remember your parameter order that is probably inconvenient for them? 

#### Arbitrary order?

How about they can pass the parameters in an arbitrary order as they want?

```
ssin('A', 2, 'f', 440, 'L', 0.8, 'fs', 48e3, 'phi', 45)
```

Okay, this function is really user friendly now. 

#### A shorter way?

Do your users like to type a lot of commas and apostrophes? I don't think so. How about this function call?

```
ssin('A f L fs phi', 2, 440, 0.8, 48e3, 45)
```

With __Simple Input Parser__ this is still a valid input for a function! 

#### An even shorter way?

Well, there is much less character to type, but I can see repeated spaces between the keys. Do you want to force your users to type spaces if they don't necessary want to? What if they can left the spaces?

```
ssin('AfLfsphi', 2, 440, 0.8, 48e3, 45)
```

Yes, this is the most compact form of a function call with __Simple Input Parser__ that produces values. Do you think this is useful for you?

There is an even shorter form that is called _Flag mode_ which receives only the keys and returns a boolean array based on the keys the user passes in.

And here comes the best part:

#### Simple Input Parser supports all its modes simultaneously by calling only one API function inside your function!


Don't hesitate to try it out.

# How to use it?

__Simple Input Parser__ does all of the internal parsing based on a predefined parameter array you pass in during the parsing API function call.

Let's say you are going to create a function that takes 3 parameters: a, b and c. Beside your custom functionality you need to
- pass the parameters in as a single varargin parameter
- create a parameter array and set the default values
- pass these two into the `simple_input_parser()` function
- you are done

``` matlab
function ret = my_function( varargin )

    params.a = 42;
    params.b = 'answer';
    params.c = 55.3;

    params = simple_input_parser(params, varargin);

    % further functionalities

end
```
By declaring a default data array you have done two things at once: 
- defining the names of the parameters
- defining it's type

This is enough information for __Simple Input Parser__ to parse the given input, and during the parsing, executing a simple type checking.

The `simple_input_parser()` API function returns the parameter array with the updated values in it.

#### What has just happened?

Inside the parsing function three things are happening:

- mode selection
- parsing
- error checking

Based on the given inputs, __Simple Input Parser__ will determine it's mode of operation and parse the input according to it.

### Offered modes of operations

__Simple Input Parser__ can work in four operation modes. The decision will be made under the hood based on the provided parameters. You only need to _call_ only _one API function_ that will handle the input parsing for you.

#### Key value pair mode

This mode is the longest method to type for your users but it is also the most clearer one. You pass in a key, and then the appropriate value. It's that simple.

```
ssin('A', 2, 'f', 440, 'L', 0.8, 'fs', 48e3, 'phi', 45)
```


#### Bulk mode

Bulk mode allows your users to pass in the keys at once, and than list the values in the given order. White spaces between the keys are optional. __Simple Input Parse__ can handle the keys without white spaces as well.

```
ssin('A f L fs phi', 2, 440, 0.8, 48e3, 45)
ssin('AfLfsphi', 2, 440, 0.8, 48e3, 45)
```

Aha, you may think that without spaces Simple Input Parser can be confused by passing ambiguous key names in it. Sadly, it can handle them happily :)

```
my_function('f fs ff2',5,0,3)
my_function('ffsff2',5,0,3)
my_function('ff2ffs',3,5,0)
```

All of these function calls are valid and they will be resulted to the same parameter assignment inside your fuction.



#### Flag mode

In flag mode you pass only a key-list and no values to your function. You need to create a default parameter array to define the key names, but you need to pass an array that's values are all zeros. This required due to the flag mode will flag the appropriate array elements whit a one value that's key is present in the given input key-list.

``` matlab
function ret = my_function( varargin )

    flags.a = 0;
    flags.b = 0;
    flags.c = 0;

    flags = simple_input_parser(flags, varargin{1});
    
    % by passing just the first element of the varargin array we make sure that the 
    % Simple Input Parser uses the flag mode
    
    % further functionalities

end
```

#### Extra flag mode

You can get a flag structure at any time, if you use a secondary output variable. This secondary output parameter will be assigned the same flag structure, as provided in the Flag mode.

``` matlab
function ret = my_function( varargin )

    params.a = 0;
    params.b = 0;
    params.c = 0;

    [params, flags] = simple_input_parser(flags, varargin);
    
    % if a value was parsed, it's corresponding field in the flags structure will 
    % be assigned to one unlike the previous flag mode, it is not necessary to 
    % truncate the varargin parameter to it's firts element the flag generation 
    % will work during other modes as well

    % further functionalities

end
```




## Custom validators

There is an optional third argument of the `simple_input_parser()` function which provides a way to pass custom validator functions to __Simple Input Parser__ thats are used for validate your values in a way you want.

For this purpose you have to construct a validator array that has the references for the validator functions you want to use for the keys. You  don't have to define a validator for every key. 

The validator functions have to return a boolean value that determines if the validation was successful or not.

``` matlab
function ret = my_function( varargin )

    params.a = 0;
    params.b = 0;
    params.c = 0;
    
    function [validflag, errormsg] = validate_c(value)
        errormsg = 'Parameter c has to be greater than 1..';
        validflag = value > 1;
    end

    validators.b = @validate_c;

    params = simple_input_parser(params, varargin, validators);

    % further functionalities

end
```

By calling the function with `my_function('abc',1,0,3)`, Simple Input Parser will provide the following error message:

```
SimpleInputParser:validationError - Invalid value was found for the key "b" according 
to the given validator function:      0

 Parameter c has to be greater than 1..
```

In this way you can provide your customers a detailed error message.

## Contribution

If you want to contribute to this project you have to make sure, that your contribution don't violates the test harness located in the `test` folder of each port.

If a pull request fails any of the tests, the request will be automatically invalidated.

The current _MATLAB_ port contains 35 tests:

```
Running SimpleInputParserTests
..........
..........
..........
.....
Done SimpleInputParserTests
__________

                 result              
    _________________________________

    [1x35 matlab.unittest.TestResult]
```

## License

This project is under the __MIT license__. 
See the included license file for further details.

