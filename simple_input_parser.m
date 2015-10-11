function [default_struct_out, extra_flags_out] = simple_input_parser( default_struct, raw_varargin, validators )
%SIMPLE_INPUT_PARSER is a varargin parser mechanism that provides a
%convenient way to enchance your custom function parameter handling.
%
% To use this mechanism you only need to pass the varargin matlab
% parameter passed to you function to the simple_input_parser function as 
% well as the default parameter set. The default parameter set defines the
% default values and in the other hand the type of the parmeters. Simple
% Input Parser uses this type information for a simple type checking.
% 
% Detailed information can be found at https://github.com/tiborsimon/simple-input-parser
%
% The MIT License (MIT)
% 
% Copyright (c) 2015 Tibor Simon
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

%% Customizable parameters

% In case of a parsing error, select if you want to terminate your program
% with an error, or catch an exception on your own.
RETHROW_EXCEPTIONS = true;

% Name that presents on the exception and error message header. There
% shold be only characters in it. No special characters nor whitespaces.
MODULE_NAME = 'SimpleInputParser';

%% Global parameters
default_struct;
raw_varargin;
ambiguous_keys     = {}; 
ambiguous_keys_initial     = {};
bulk_parsed_keys   = {};
keys               = fieldnames(default_struct);
varlen             = length(raw_varargin);
extra_flags_mode   = 0;

default_struct_out = {};
extra_flags_out    = {};

%% Mode selection and error handling logic
try
    % Handle missing parameters
    switch nargin
        case 0
            % Called with no parameters SimpleInputParser will run in demo mode
            disp(' ');
            disp(' Simple Input Parser demo mode.');
            disp('  Status:   working');
            disp('  This message was appeared due to no input parameters were passed to the function.');
            disp('  Have a nice day!');
            disp(' ');
            return;
        case 1
            raw_varargin = {};
            validators = {};
        case 2
            % if validators are not passed, set them to empty
            validators = {};
    end
    if nargin > 3
        throw_exception('API_error_tooMuchParameters', 'To much API input parameters. The max number is 3.');
    end

    % Handle output parameters
    switch nargout
        case 0
        case 1
            extra_flags = 0;
        case 2
            for index=1:size(keys)
                extra_flags.(keys{index}) = 0;
            end
            extra_flags_mode = 1;
        otherwise
            throw_exception('API_error_tooMuchParameters', 'To much API output parameters. The max number is 2.');
    end

    switch varlen
        case 1
            throw_exception('invalidParameterLength', 'Invalid input paramter length. At least 2 parameters required. A key and a value.');
        case 2
            parse_bulk_values();
        otherwise
            first_element = raw_varargin{1};
            if ismember(first_element, keys) && mod(varlen,2) ~= 1
                parse_key_value_pairs();
            else
                parse_bulk_values();
            end
    end
    default_struct_out = default_struct;
    extra_flags_out = extra_flags;
catch exception
    if RETHROW_EXCEPTIONS
        throw(exception);
    else
        disp(' ');
        disp(['ERROR ' exception.identifier, ' - ', exception.message]);
        disp(' ');
    end
end
    
%% Bulk mode
    function parse_bulk_values()
        parse_raw_key_string();
    end

    function parse_raw_key_string()
        check_for_ambigous_keys();
        ambiguous_keys_initial = ambiguous_keys;
        parseable_keys = raw_varargin{1};
        value_index = 2;
        while length(parseable_keys)  % loop until there are characters in the raw key-string
            [keys, parseable_keys, value_index, ambi_ret] = match_raw_keys_for_value_index(keys, parseable_keys, value_index, false);
        end
        if value_index == varlen
            throw_exception('unusedValue', ['There were more values than keys provided. There is ', num2str(varlen-value_index+1), ' value left unused.']);
        end
        if value_index < varlen
            throw_exception('unusedValue', ['There were more values than keys provided. There are ', num2str(varlen-value_index+1), ' values left unused.']);
        end
    end

    function check_for_ambigous_keys()
        key_list = fieldnames(default_struct);
        key_count = length(key_list);
        for k=1:(key_count-1)
            for kk = k+1:key_count
                key1 = key_list{k};
                key2 = key_list{kk};
                if 0 < regexp(key1, strcat('^', key2));
                    ambiguous_keys = append_cell_to_array(ambiguous_keys, key2);
                end
                if 0 < regexp(key2, strcat('^', key1));
                    ambiguous_keys = append_cell_to_array(ambiguous_keys, key1);
                end
            end
        end
    end

    function [updated_key_list, truncated_parseable_keys, value_index, ambi_ret] = match_raw_keys_for_value_index(key_list, parseable_keys, value_index, ambi_call)
        l = length(key_list);
        ambi_ret = false;
        k = 1;
        while k  % run through all the keys remainded
            if k == l+1
                throw_exception('invalidKey', ['The token "', parseable_keys, '" is invalid! No match found for the first characters in it. Parsing aborted..\n\nPossible solutions:\n  - Make sure you pass a key only once. Duplicated keys will abort the parsing.\n  - Make sure you only use valid keys. Look for valid keys in the documentation.']);
            end
            try
                current_key = key_list{k};
            catch
                if check_for_redundant_keys(parseable_keys)
                    throw_exception('redundantKey', ['The key in front of "', parseable_keys, '" was parsed before. Use a key only once!']);
                end
                throw_exception('unparsedToken', ['Tokens "', parseable_keys, '" was remained after all available parameters were parsed.']);
            end
            if check_for_redundant_keys(parseable_keys)
                throw_exception('redundantKey', ['The key in front of "', parseable_keys, '" was parsed before. Use a key only once!']);
            end
            [x, y] = regexp(parseable_keys, get_regexp_pattern_for_key(current_key));
            if x > 0
                if ismember(current_key, ambiguous_keys_initial)
                    amb_truncated_keys = remove_cell_from_array(key_list, current_key);
                    try
                        [returned, parseable_keys, value_index, ambi_ret] = match_raw_keys_for_value_index(amb_truncated_keys, parseable_keys, value_index, true);
                        if ambi_ret && ambi_call
                            updated_key_list = key_list;
                            truncated_parseable_keys = parseable_keys;
                            break
                        end
                        ambiguous_keys = remove_cell_from_array(ambiguous_keys, current_key);
                        returned = append_cell_to_array(returned, current_key);
                        d = setdiff(key_list, returned);
                        key_list = remove_cell_from_array(key_list, d{1});
                        l = l-1;
                        if length(parseable_keys) > 0
                            continue
                        else
                            updated_key_list = key_list;
                            truncated_parseable_keys = parseable_keys;
                            break
                        end
                    catch exception
                        disp(exception)
                    end
                end
                if value_index > length(raw_varargin)
                   throw_exception('missingValue', 'There were more keys than values passed! Parsing aborted..');
                end
                assert_if_value_for_key_is_invalid(current_key, raw_varargin{value_index});
                overwrite_value_for_key(current_key, raw_varargin{value_index});
                updated_key_list = remove_cell_from_array(key_list, current_key);
                [truncated_parseable_keys, removed_key] = remove_string_head_until_index(parseable_keys,y);
                value_index = value_index + 1;
                bulk_parsed_keys = append_cell_to_array(bulk_parsed_keys, removed_key);
                ambi_ret = true;
                break
            end
            k = k+1;
        end
    end

    function pattern = get_regexp_pattern_for_key(key)
        pattern = strcat('^',key, '\s*');
    end
        
    function [shorter_string, removed_string] = remove_string_head_until_index(string, index)
        if length(string) == index
            removed_string = string;
            string = '';
        else
            removed_string = string(1:index);
            string = string(index+1:end);
        end 
        shorter_string = string;
    end

    function result = check_for_redundant_keys(remained_keys)
       for kk=1:length(bulk_parsed_keys)
           pattern = get_regexp_pattern_for_key(bulk_parsed_keys{kk});
           m = regexp(remained_keys, pattern, 'match');
           if ~ismember(m, ambiguous_keys_initial)
               result = 1;
               return
           end
       end
       result = 0;
    end

%% Key value pairs mode
    function parse_key_value_pairs()
        parsed_keys = {};
        if mod(varlen,2) == 1
            throw_exception('invalidParameter', 'Invalid paramter. Key provided but value is missing!');
        end
        for k = 1:2:varlen
            current_key = raw_varargin{k};
            current_value = raw_varargin{k+1};
            
            if ismember(current_key, parsed_keys)
                throw_exception('redundantKey', ['Key "', current_key, '" was parsed before. Use a key only once!']);
            end
            
            assert_if_key_is_invalid(current_key)
            assert_if_value_for_key_is_invalid(current_key, current_value)
            
            overwrite_value_for_key(current_key, current_value)
            parsed_keys = append_cell_to_array(parsed_keys, current_key, true);
            
            if length(parsed_keys) > length(keys)
                throw_exception('invalidParameterLength', 'Invalid paramter length. There are at least one unecessary key value pair!');
            end
        end
    end
    
%% Helper functions

    function updated_array = append_cell_to_array(array, value, add_already_existing)
        switch nargin
            case 2
                add_already_existing = false;
        end
        if ~ismember(value, array) || add_already_existing
            array{length(array)+1} = value;
        end
        updated_array = array;
    end

    function truncated_array = remove_cell_from_array(array, cell)
        truncated_array = {};
        l = length(array);
        for k=1:l
            if ~isequal(array{k}, cell)
                truncated_array = append_cell_to_array(truncated_array, array{k});
            end
        end
    end

    function overwrite_value_for_key(key, value)
        validate_value_for_key(key, value);
        default_struct.(key) = value;
        if extra_flags_mode
            extra_flags.(key) = 1;
        end
    end

    function validate_value_for_key(key, value)
        if size(validators,2) ~= 0
            if isfield(validators, key)
                [validflag, errormsg] = validators.(key)(value);
                if ~validflag
                    throw_exception('validationError', ['Invalid value was found for the key "', key, '" according to the given validator function: ', evalc('disp(value)'), ' ', evalc('disp(errormsg)')]);
                end
            end
        end
    end

%     function value = get_varargin_element_for(index)
%         value = raw_varargin{index};
%     end

    function result = is_key_valid(key)
        result = ischar(key) && ismember(key, keys);
    end
    
    function result = is_key_value_pair_valid(key, value)
        result = isa(value, class(default_struct.(key)));
    end
    
    function assert_if_key_is_invalid(key)
        if ~ischar(key)
            throw_exception('invalidKey', [num2str(k), '. key is not a string!']);
        end
        if ~ismember(key, keys)
            throw_exception('invalidKey', ['Key "', key, '" is invalid! No matching valid parameter was found.']);
        end
    end

    function assert_if_value_for_key_is_invalid(key, value)
        if ~is_key_value_pair_valid(key, value)
            throw_exception('typeError', ['The value for the key "', key, '" is a ', class(key), ' instead of a ', class(default_struct.(key)), '!']);
        end
    end

    function throw_exception(header, message)
        id = [MODULE_NAME, ':', header];
        exception = MException(id, message);
        throw(exception)
    end

end
