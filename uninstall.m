%% MATLAB Library System uninstallation script
% By running this script the content of the current folder's `library` folder 
% will be removed from the MATLAB path permamently on your system.

% IMPORTANT: before you run the script navigate your Current Folder to the
% DSP Sandbox repo root, otherwise the installation will be unsuccessful..

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

function uninstall()
    disp(' ');
    if core_checkenvironment(dir);

        [name, version, message] = core_getlibrarydata();

        disp(' ');
        disp('======================================================================================');
        disp([' MATLAB Library System: uninstalling ', name, ' ', version, '..']);
        disp('--------------------------------------------------------------------------------------');

        rootDirectory = strcat(pwd,'\');

        allLibraryDirectories = regexp(genpath('library'),['[^;]*'],'match');
        
        for k=1:length(allLibraryDirectories)
            newPath = strcat(rootDirectory,allLibraryDirectories{k});
            lastwarn('')
            warning ('off','all');
            rmpath(newPath);
            warning ('on','all');
            if ~strcmp(lastwarn,'')
                disp('   WARNING: Your library has been uninstalled already..');
                break;
            end
            disp(['   path removed: ', newPath]);
        end

        savepath;

        disp('--------------------------------------------------------------------------------------');
        disp([' ', name, ' ', version, ' has been successfully uninstalled from your system!']);
        disp('======================================================================================');
        clear name version newPath rootDirectory allLibraryDirectories
    else
        error('Error: You are in the wrong folder! Make sure you navigate to the root folder of your library that contains the uninstall script!');
    end
    
    clear ans currentFolders result k
end

function [ ret ] = core_checkenvironment( currentFolders )
    result = 0;
    for k=1:length(currentFolders);
        if strcmp(currentFolders(k).name,'library')
            result = result + 1;
        end
    end
    ret = result == 1; 
end

function [ name, version, message ] = core_getlibrarydata()
    fileID = fopen('librarydata.txt');
    name = fgetl(fileID);
    version = fgetl(fileID);
    message = fgetl(fileID);
    fclose(fileID);
end
