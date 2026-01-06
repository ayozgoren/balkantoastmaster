classdef ToastAudio
    % TOASTAUDIO - Audio Player Helper
    
    methods (Static)
        function duration = playAndWait(filename)
            % Play sound and return
            duration = 2.0; 
            
            try
                if exist(filename, 'file')
                    [y, Fs] = audioread(filename);
                    sound(y, Fs);
                    duration = length(y) / Fs;
                else
                    fprintf('Warning: Audio file %s not found.\n', filename);
                end
            catch
                fprintf('Error trying to play audio.\n');
            end
        end
    end
end