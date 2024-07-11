classdef ClipAndTry < handle
    % ClipAndTry class monitors the clipboard and triggers a user-defined function when the content changes.
    % Usage:
    %   myClip = ClipAndTry(@(content) disp(['Clipboard changed: ', content]));
    %   To stop monitoring: stop(myClip.TimerObj);
    properties
        TimerObj
        LastClipboardContent = ''
        UserFunction
    end
    
    methods
        function obj = ClipAndTry(userFunction)
            % Constructor: Initialize the timer object to run every second
            if nargin < 1
                obj.UserFunction = @(clipboardContent) fprintf('Clipboard content: %s\n', clipboardContent);
            else
                obj.UserFunction = userFunction;
            end
            obj.LastClipboardContent = clipboard('paste');
            obj.TimerObj = timer('TimerFcn', @(~,~)obj.checkClipboard(), ...
                                 'Period', 1, ...
                                 'ExecutionMode', 'fixedRate');
            start(obj.TimerObj);
            fprintf('Monitoring clipboard. To stop, type "stop(obj.TimerObj)" in the command window.\n');
        end
        
        function checkClipboard(obj)
            % Get the current clipboard content
            clipboardContent = clipboard('paste');
            
            % If the clipboard content is different from the last content, execute the user-defined function
            if ~strcmp(clipboardContent, obj.LastClipboardContent)
                obj.UserFunction(clipboardContent);
                obj.LastClipboardContent = clipboardContent;
            end
        end
        
        function set.UserFunction(obj, newFunction)
            % Method to change the user-defined function
            obj.UserFunction = newFunction;
        end
        
        function delete(obj)
            % Destructor: Stop and delete the timer object when the class object is deleted
            stop(obj.TimerObj);
            delete(obj.TimerObj);
        end
    end
end
