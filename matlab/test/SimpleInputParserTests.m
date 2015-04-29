classdef SimpleInputParserTests < matlab.unittest.TestCase
    
    methods (Test)
        
%% Base Mode
        function test_BaseMode_BasicFunctionality(testCase)
            data.a = 1;
            
            raw_varargin = {'a', 42};
            
            expected.a = 42;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BaseMode_MultipleParameters(testCase)
            data.a = 1;
            data.b = 2;

            raw_varargin = {'a', 42, 'b', 12};

            expected.a = 42;
            expected.b = 12;

            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BaseMode_ReverseOrder(testCase)
            data.a = 1;
            data.b = 2;

            raw_varargin = {'b', 12, 'a', 42};

            expected.a = 42;
            expected.b = 12;

            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BaseMode_InvalidFirstKey(testCase)
            data.a = 1;
            data.b = 2;

            raw_varargin = {'invalid', 12, 'a', 42};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:invalidKey')
        end
        
        function test_BaseMode_InvalidSecondKey(testCase)
            data.a = 1;
            data.b = 2;

            raw_varargin = {'a', 12, 'invalid', 42};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:invalidKey')
        end
        
        function test_BaseMode_InvalidThirdKey(testCase)
            data.a = 1;
            data.b = 2;
            data.c = 3;

            raw_varargin = {'a', 12, 'c', 12, 'invalid', 42};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:invalidKey')
        end
        
        function test_BaseMode_RedundantKeys(testCase)
            data.a = 1;
            data.b = 2;

            raw_varargin = {'a', 12, 'a', 12};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:redundantKey')
        end
        
        function test_BaseMode_ValueError(testCase)
            data.a = 1;
            data.b = 2;

            raw_varargin = {'a', 12, 'b', 'hello'};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:typeError')
        end
        
%% Bulk Mode
        function test_BulkMode_BasicFunctionality(testCase)
            data.a = 1;
            
            raw_varargin = {'a', 42};
            
            expected.a = 42;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseTwoKeys(testCase)
            data.a = 1;
            data.b = 1;
            
            raw_varargin = {'ab', 42, 12};
            
            expected.a = 42;
            expected.b = 12;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseTwoKeysWithWhitespace(testCase)
            data.a = 1;
            data.b = 1;
            
            raw_varargin = {'a  b  ', 42, 12};
            
            expected.a = 42;
            expected.b = 12;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseReversedTwoKeys(testCase)
            data.a = 1;
            data.b = 1;
            
            raw_varargin = {'ba', 42, 12};
            
            expected.a = 12;
            expected.b = 42;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseReversedTwoKeysWithWhitespace(testCase)
            data.a = 1;
            data.b = 1;
            
            raw_varargin = {'b   a         ', 42, 12};
            
            expected.a = 12;
            expected.b = 42;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseAmbiguousTwoKeys(testCase)
            data.f = 1;
            data.fs = 1;
            
            raw_varargin = {'fsf', 48e3, 6000};
            
            expected.f = 6000;
            expected.fs = 48e3;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseAmbiguousTwoKeysWithWhitespaces(testCase)
            data.f = 1;
            data.fs = 1;
            
            raw_varargin = {'fs   f', 48e3, 6000};
            
            expected.f = 6000;
            expected.fs = 48e3;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseAmbiguousLotOfKeysWithoutRepetition(testCase)
            data.f = 1;
            data.fs = 1;
            data.fsd = 1;
            data.fsdh = 1;
            data.fsdhj = 1;
            data.fsdhjk = 1;
            
            raw_varargin = {'fsdhjkfsdhjfsdhfsdfsf', 2,3,4,5,6,7};
            
            expected.f = 7;
            expected.fs = 6;
            expected.fsd = 5;
            expected.fsdh = 4;
            expected.fsdhj = 3;
            expected.fsdhjk = 2;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseAmbiguousTwoKeysWithRepetition(testCase)
            data.f = 1;
            data.ff = 1;
            
            raw_varargin = {'fff', 2, 3};
            
            expected.f = 3;
            expected.ff = 2;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_ParseAmbiguousTwoKeysWithRepetitionAndWhitespaces(testCase)
            data.f = 1;
            data.ff = 1;
            
            raw_varargin = {'f ff', 2, 3};
            
            expected.f = 2;
            expected.ff = 3;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_BulkMode_KeyError(testCase)
            data.a = 1;
            data.b = 1;
            
            raw_varargin = {'av', 42, 12};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:invalidKey')
        end
        
        function test_BulkMode_KeyErrorWithAmbiguousKey(testCase)
            data.f = 1;
            data.fs = 1;
            
            raw_varargin = {'fvf', 42, 12};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:invalidKey')
        end
        
        function test_BulkMode_TooMuchKey(testCase)
            data.a = 1;
            data.b = 1;
            
            raw_varargin = {'abc', 42, 12};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:invalidKey')
        end
        
        function test_BulkMode_TooMuchValue(testCase)
            data.a = 1;
            
            raw_varargin = {'a', 42, 12};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:unparsedValues')
        end
        
        function test_BulkMode_InvalidValueType(testCase)
            data.a = 1;
            data.b = 1;
            
            raw_varargin = {'ab', 42, 'dfdf'};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin), 'SimpleInputParser:typeError')
        end
        
%% Flag Mode
        function test_FlagMode_BasicFunctionality(testCase)
            data.a = 0;
            
            raw_varargin = {'a'};
            
            expected.a = 1;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_FlagMode_ParseTwoKeys(testCase)
            data.a = 0;
            data.b = 0;
            
            raw_varargin = {'ab'};
            
            expected.a = 1;
            expected.b = 1;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_FlagMode_TwoKeysButParsedOnlyOne(testCase)
            data.a = 0;
            data.b = 0;
            
            raw_varargin = {'a'};
            
            expected.a = 1;
            expected.b = 0;
            
            result = simple_input_parser(data, raw_varargin);
            testCase.verifyEqual(expected, result);
        end
        
        function test_FlagMode_WarningIfDefaultAreNotZero(testCase)
            data.a = 6;
            
            raw_varargin = {'a'};
            
            testCase.verifyWarning(@() simple_input_parser(data, raw_varargin), '')
        end
        
%% Validator tests
        function test_Validator_BasicFunctionality_Passed(testCase)
            data.a = 'gg';
            
            validator.a = @ischar;
            
            raw_varargin = {'a', 'f'};
            
            expected.a = 'f';
            
            result = simple_input_parser(data, raw_varargin, validator);
            testCase.verifyEqual(expected, result);
        end
        
        function test_Validator_BasicFunctionality_Failed(testCase)
            data.a = 1;
            
            validator.a = @ischar;
            
            raw_varargin = {'a', 42};
            
            testCase.verifyError(@() simple_input_parser(data, raw_varargin, validator), 'SimpleInputParser:validationError')
        end

    end
end