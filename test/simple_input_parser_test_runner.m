clear all
close all
clc

%% Run test suite
suite = matlab.unittest.TestSuite.fromFile('SimpleInputParserTests.m');
result = run(suite);
rt = table(result);
disp(rt)