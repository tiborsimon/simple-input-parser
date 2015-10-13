# Simple Input Parser

Easy to use variable lenght input parser mechanism that provides a convenient and advanced way to enchance your custom function parameter handling.

The current version sports a _MATLAB_ implementation, but other language ports are coming too.

<a title="Latest version" href="https://github.com/tiborsimon/simple-input-parser/releases/latest" target="_blank">
   <img src="https://img.shields.io/badge/version-v2.4.0-green.svg?style=flat" />
</a>
<a title="Goto article" href="http://tiborsimon.io/projects/TSPR0002/" target="_blank">
   <img src="https://img.shields.io/badge/article-read-blue.svg?style=flat" />
</a>
<a title="Goto discussion" href="http://tiborsimon.io/projects/TSPR0002/#discussion" target="_blank">
   <img src="https://img.shields.io/badge/discussion-join-orange.svg?style=flat" />
</a>
<a title="License" href="#license">
   <img src="http://img.shields.io/badge/license-MIT-green.svg?style=flat" />
</a>

## Documentation v2.4.0

What would you do in a situation, when you want to use a third party function or library, but the only documentation is a usage example?

```
% use this function to generate a sine wave
ssin(440, 2, 45, 48e3, 0.8)
```

Well, unless you are despearte enough to dvelve into the souce code to figure out which parameter is which this function is pretty useless for you.

## Key-value pair mode

It would be much more useful, if there would be a built in guide that is self-explanatory. Do you prefer this way instead?

```
ssin('f', 440, 'A', 2, 'phi', 45, 'fs', 48e3, 'L', 0.8)
```

You know exactly what you are going to do in this case. You type a bit more, but the function call is self-explanatory for everyone else, and this is exactly what __Simple Input Parser__ provides for you in the first place. This mode is called _key-value pair mode_.

But. If you want to use this function, you will have to remember the exact order of the parameters. If a function has more than 4 or 5 parameters you will have a hard time remembering what goes to another. What if there would be no parameter order constrain at all? With __Simple Input Parser__ you can pass your _key-value_ pairs in any order you like.

## Bulk mode

How about writing less apostrophes?

```
ssin('A f L fs phi', 2, 440, 0.8, 48e3, 45)
```

This is the _bulk mode_ of __Simple Input Parser__. You write the keys first as a string, and the the values in the order you have specified before. Same self-explanatory function call with less apostrophes and commas to write.

How about this function call?

```
ssin('AfLfsphi', 2, 440, 0.8, 48e3, 45)
```

Well, this is still the _bulk mode_ and it is completely valid with __Simple Input Parser__. A little less self-explanatory, bat it is incredible fast to write. Feel free to use it whenever you want.


## All features

We have discussed the first three features of __Simple Input Parser__ which would be useful for the _users_ that are using the functions equiped with __Simple Input Parser__, but the are another three very useful features for the _developers_ as well.

| For the users | For the developers |
|:--------------|:-------------------|
| 1. Arbitrary parameter order | 4. Extra flag mode |
| 2. Key value pair mode | 5. Automatic parameter validation by type |
| 3. Bulk mode | 6. Custom validator functions with custom error messages |

Before we go into the details of the final three featurea, you have to install __Simple Input Parser__.


## Installation as an MLS package

In the <a href="https://github.com/tiborsimon/simple-input-parser/releases/latest" target="_blank">latest release page</a> you can find the MLS package containing Simple Input Parser. This method provides a simple and easy installation.

1. Download and unpack the [latest release](https://github.com/tiborsimon/simple-input-parser/releases/latest) into your machine.
1. Navigate into the unpacked folder and run the `install` command or open up and run the `install.m` script.
1. Done. Now you have __Simple Input Parser__ on your system.

_MLS packages are powered by the <a href="http://tiborsimon.io/projects/#TSPR0001" target="_blank" >MATLAB Library System</a>._ Go to that link to find oup more about this systemIt's a good practice to keep all your MLS packages in a common folder and use the <a href="http://tiborsimon.io/projects/TSPR0001/#Bestpractice" target="_blank">install_all.m</a> script to install all your packages at once.

## Installation in the traditional way
If you are not interested in the MLS package system, yu can still download the pure [__Simple Input Parser__ source files](https://github.com/tiborsimon/simple-input-parser/releases/latest), and you can install/include them manually anywhere you want.

## Basic usecase

Let's say you want to write a function with __Simple Input Parser__ that expects three parameters: `a`, `b`, `c`. Your can write this function in the usual way except three things:

1. You have to use _varargin_ for the parameter list.
2. You have to create a _parameter structure_ that will contain your parameters and it's default values.
3. You have to call the `simple_input_parser()` api function with the _parameter structure_ and the _varargin_ parameter, and use the previously created _parameter structure_ for the output parameter.

```
function ret = my_function(varargin)

    params.a = 42;
    params.b = 'answer';
    params.c = 55.3;

    params = simple_input_parser(params, varargin);

    % further functionalities that uses the params struct

end
```

__Congratulation!__ With these _three_ simple modifications you have implemented _four_ features from the _six_ __Simple Input Parser__ features!

To name this four features:

- `my_function()` can accept it's parameters in an arbitrary order
- It will support the _key-value pair_ mode..
- ..as well as the _bulk mode_. Mode selection is automatic.
- It will perform an automatic parameter type validation, since you have implicitly defined your parameter's types.

The `simple_input_parser()` function will return with the modified parameter structure. If the user did not passed the parameter, the default value will be left in there that you have specified earlier.


## Extra flag mode

In some situations it might be useful, if you know, what parameters have your function got. At this point you might think, it can be implemented comparing the values in the parameter struct with it's default values. Well it is a reasonable method, but __Simple Input Parser__ offers an easier one.

You can call the `simple_input_parser()` function with two input parameters. The first one is the output parameter structure and the second one is the __flag structure__. This mode is called _Extra flag mode_. 

```
function ret = my_function(varargin)

	params.a = 0;
    params.b = 0;
    params.c = 0;

    [params, flags] = simple_input_parser(params, varargin);
    
    if flags.b
    	disp('b parameter was passed');
    end

    % further functionalities
end
```

If a value was parsed, it's corresponding field in the flags structure will be assigned to one. It provides you a convenient way to handle custom cases that are depend on the passed parameters.

## Validator functions

__Simple Input Parser__ provides an interface to easily create custom _validator functions_. If the default automatic type based validation isn't enough for you, you can use more specific _validator functions_ for each parameters if you want. For this purpose you have to create a nested validator function with a fix signature: 

```
function [validflag, errormsg] = my_validator_for_the_parameter_c(value)
	validflag = value > 1;
	errormsg = 'Parameter c has to be greater than 1..';
end
```

| Input |
|:-------|
| _value_ - Parameter value that passed to the function. |

| Output |
|:-------|
|_validflag_ - Validation result. It is _true_ if the paramter passed the validation. |
|_errormsg_ - Message that will be displayed if the validation fails. |

You can use any logic you want to generate the validation result (_validflag_) and the custom error message (_errormsg_) based on the given parameter value (_value_). 

To specify which _validator function_ belongs to which parameter, you need to create a structure with fields identical to the parameters you want to validate, assigning a pointer pointing to the _validator function_. __Simple Input Parser__ will call this _validator function_ with the parameter's value if it parses the specified parameter, and based on the returned value (_validflag_) it will throw an error with the specified error message (_errormsg_).

The custom validation is optional, so you don't need to specify a _validator function_ for each parameters. If a parameter doesn't has a _validator function_ the default automatic type based validation will be used for that parameter.

```
function ret = my_function(varargin)

    params.a = 0;
    params.b = 0;
    params.c = 0;

    function [validflag, errormsg] = my_validator_for_the_parameter_c(value)
		validflag = value > 1;
		errormsg = 'Parameter c has to be greater than 1..';
	end

    validators.c = @validate_c;

    params = simple_input_parser(params, varargin, validators);

    % further functionalities

end
```

You can use one _validator function_ for more than one parameters, but keep in mind that you will get only a value without any information for the parameter name.

## Error handling

There is a parameter called `RETHROW_EXCEPTIONS` that you can edit in the `simple_input_parser.m` file. This variable allows you to control the libary's behavior in case of error. __Simple Input Parser__ has two error handling modes:

|`RETHROW_EXCEPTIONS` | In case of an error `simple_input_parser()`.. |
|:-------------|:--------------|
|_true_ | will throw an exception. |
|__false__ | will stop the execution and print out the error. |

The default value is __false__, so in case of an error, the `simple_input_parser()` function will gently stop the execution, and it will display the default error messages shipped with __Simple Input Parser__. 

If you want to display your own error messages for the error ceses, you can use _custom validator functions_ and/or you can turn on the `RETHROW_EXCEPTIONS` flag inside the `simple_input_parser.m` file, and catch the exceptions that `simple_input_parser()` function throws to you.

### Exception format

Since MATLAB's exception system uses exception identifiers instead of exception classes and subclasses, __Simple Input Parser__ uses the following exception format for the exception identifier:

_component:mnemonic_ = `SimpleInputParser:exceptionId`

|exceptionId | Error case |
|:-------------|:--------------|
|_invalidParameterLength_ | There were less than 2 or there were more than enough parameters passed to the function. |
|_invalidKey_ | The parsed key is invalid since no matching parameter was found. |
|_redundantKey_ | A key passed two times. |
|_unusedValue_ | There were more values than keys specified. |
|_typeError_ | A parsed value didn't passed the automatic type based validation. |
|_validationError_ | A parsed value didn't passed the corresponding custom validatior function. | 


## Contribution

If you want to contribute to this project you have to make sure, that your contribution don't violates the test harness located in the `test` folder of each port.

If a pull request fails any of the tests, the request will be automatically invalidated.

The current _MATLAB_ port contains 33 tests:

```
Running SimpleInputParserTests
..........
..........
..........
...
Done SimpleInputParserTests
__________

                 result              
    _________________________________

    [1x33 matlab.unittest.TestResult]
```

## License

This project is under the __MIT license__. 
See the included license file for further details.
