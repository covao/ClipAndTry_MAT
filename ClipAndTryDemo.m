% ClipAndTryDemo.m
%
% Run this script and then copy the code that ChatGPT generates.
%
% # ChatGPT Prompt Example
% ## Create the following MATLAB function
% - Function name: plot_test
% - Plot an example using meshgrid()
%
% ## Create the following class for MATLAB system block
% - Class name:add_noise
% - Input: Vector signal
% - Output: Vector signal
% - Parameter: Level of noise
% - Processing: Add white noise to the input signal
%

% Define the user function that will be executed when the clipboard content changes
userFunction = @(clipboardContent) checkAndExecuteFunction(clipboardContent);

% Create an instance of ClipAndTry with the user-defined function
monitor = ClipAndTry(userFunction);

% Instructions to the user
fprintf('Copy some text to the clipboard. If the first line is a class(MATLAB System) or function definition, it will be processed accordingly.\n');
fprintf('To stop the clipboard monitor, type "clear or stop(monitor.TimerObj)" in the command window.\n');

% Define the function to check if the first line of the clipboard content is a class or function definition
function checkAndExecuteFunction(clipboardContent)
    % Split the clipboard content into lines
    lines = strsplit(clipboardContent, '\n');
    if ~isempty(lines)
        firstLine = strtrim(lines{1});
        
        % Define the class pattern
        classPattern = 'classdef\s+(\w+)\s*<\s*matlab\.System';
        % Match the first line with the class pattern
        classNameMatches = regexp(firstLine, classPattern, 'tokens');
        
        % Define the function pattern
        funcPattern = 'function\s+.*?\s*=\s*(\w+)\s*\(.*\)|function\s+(\w+)\s*\(.*\)';
        % Match the first line with the function pattern
        funcNameMatches = regexp(firstLine, funcPattern, 'tokens');
        
        if ~isempty(classNameMatches)
            % Extract the class name
            className = classNameMatches{1}{1};
            % Define the file name
            fileName = [className, '.m'];
            if exist(fileName, 'file') ~= 2
                % Save the clipboard content to a file with the class name
                fid = fopen(fileName, 'wt');
                fprintf(fid, '%s', clipboardContent);
                fclose(fid);
                fprintf('Class definition saved as %s\n', fileName);

                % Create a new Simulink model
                h = new_system();
                open_system(h);
                % Add a System block to the model
                blockType = 'simulink/User-Defined Functions/MATLAB System';
                add_block(blockType, [bdroot, '/', className ]);
                set_param(gcb, 'System', className);

                fprintf('Simulink model created with System block set to %s.m\n', fileName);
            else
                % Save the clipboard content to the existing file
                fid = fopen(fileName, 'wt');
                fprintf(fid, '%s', clipboardContent);
                fclose(fid);
                fprintf('Class definition updated in %s\n', fileName);
            end
        elseif ~isempty(funcNameMatches)
            % Extract the function name
            funcName = funcNameMatches{1}{~cellfun('isempty', funcNameMatches{1})};
            % Define the file name
            fileName = [funcName, '.m'];
            % Save the clipboard content to a file with the function name
            fid = fopen(fileName, 'wt');
            fprintf(fid, '%s', clipboardContent);
            fclose(fid);
            fprintf('Function saved as %s\n', fileName);
            % Execute the saved function file
            run(fileName);
        else
            % fprintf('Failed to extract class or function name from: %s\n', firstLine);
        end
    end
end
