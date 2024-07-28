function closeGUI(~, ~)
global s hFig hTimer

    % Stop timer
    % stop(hTimer);
    % delete(hTimer);
    
    % Close serial port
    delete(s);
    
    % Close GUI
    delete(hFig);
end