% £ukasz Lepak, 277324
% MZMO, projekt 17Z
% porÛwnanie regulatorÛw PID
% prowadzπcy: dr inø. Krystian KrÛl

clear all;
close all;

J = 0.01;
b = 0.1;
K = 0.01;
R = 1;
L = 0.5;

A = [-b/J, K/J; -K/L, -R/L];
B = [0; 1/L];
C = [1, 0];
D = 0;

sys = ss(A,B,C,D);
pid = pidtune(sys, 'pid');
mpc = mpc(sys, 0.1);

fig = figure;
fig.Name = 'MZMO - porÛwnanie regulatorÛw by £ukasz Lepak';
fig.NumberTitle = 'off';
fig.Resize = 'off';
fig.Position = [100 50 1280 720];

uicontrol('Style', 'text', 'Position', [240 660 150 70], 'String', 'PID', 'FontSize', 40);
uicontrol('Style', 'text', 'Position', [0 620 400 40], 'String', 'Wzmocnienie regulatora (Kp):', 'FontSize', 15, 'HorizontalAlignment', 'left');
uicontrol('Style', 'text', 'Position', [0 580 400 40], 'String', 'Czas zdwojenia (Ki):', 'FontSize', 15, 'HorizontalAlignment', 'left');
uicontrol('Style', 'text', 'Position', [0 540 400 40], 'String', 'Czas wyprzedzenia (Kd):', 'FontSize', 15, 'HorizontalAlignment', 'left');
uicontrol('Style', 'text', 'Position', [0 500 400 40], 'String', 'Sta≥a czasowa inercji (Tf):', 'FontSize', 15, 'HorizontalAlignment', 'left');
pidKp = uicontrol('Style', 'edit', 'Position', [400 620 112 40], 'String', pid.Kp, 'FontSize', 15, 'HorizontalAlignment', 'right', 'Value', pid.Kp);
pidKi = uicontrol('Style', 'edit', 'Position', [400 580 112 40], 'String', pid.Ki, 'FontSize', 15, 'HorizontalAlignment', 'right', 'Value', pid.Ki);
pidKd = uicontrol('Style', 'edit', 'Position', [400 540 112 40], 'String', pid.Kd, 'FontSize', 15, 'HorizontalAlignment', 'right', 'Value', pid.Kd);
pidTf = uicontrol('Style', 'edit', 'Position', [400 500 112 40], 'String', pid.Tf, 'FontSize', 15, 'HorizontalAlignment', 'right', 'Value', pid.Tf);
pidSave = uicontrol('Style', 'pushbutton', 'Position', [200 460 200 30], 'String', 'Zapisz zmiany');
pidLoad = uicontrol('Style', 'pushbutton', 'Position', [200 420 200 30], 'String', 'Wczytaj wartoúci z pliku pid.txt');
pidCheck = uicontrol('Style', 'pushbutton', 'Position', [200 380 200 30], 'String', 'Parametry jakoúci regulacji');

uicontrol('Style', 'text', 'Position', [240 280 150 70], 'String', 'MPC', 'FontSize', 40);
uicontrol('Style', 'text', 'Position', [0 240 400 40], 'String', 'Czas prÛbkowania (Ts > 0):', 'FontSize', 15, 'HorizontalAlignment', 'left');
uicontrol('Style', 'text', 'Position', [0 200 400 40], 'String', 'Horyzont predykcji (p > 0): ', 'FontSize', 15, 'HorizontalAlignment', 'left');
uicontrol('Style', 'text', 'Position', [0 160 400 40], 'String', 'Horyzont sterowania (1 <= m <= p): ', 'FontSize', 15, 'HorizontalAlignment', 'left');
mpcTs = uicontrol('Style', 'edit', 'Position', [400 240 112 40], 'String', mpc.Ts, 'FontSize', 15, 'HorizontalAlignment', 'right', 'Value', mpc.Ts);
mpcP = uicontrol('Style', 'edit', 'Position', [400 200 112 40], 'String', mpc.PredictionHorizon, 'FontSize', 15, 'HorizontalAlignment', 'right', 'Value', mpc.PredictionHorizon);
mpcM = uicontrol('Style', 'edit', 'Position', [400 160 112 40], 'String', mpc.ControlHorizon, 'FontSize', 15, 'HorizontalAlignment', 'right', 'Value', mpc.ControlHorizon);
mpcSave = uicontrol('Style', 'pushbutton', 'Position', [200 120 200 30], 'String', 'Zapisz zmiany');
mpcLoad = uicontrol('Style', 'pushbutton', 'Position', [200 80 200 30], 'String', 'Wczytaj wartoúci z pliku mpc.txt');
mpcCheck = uicontrol('Style', 'pushbutton', 'Position', [200 40 200 30], 'String', 'Ocena regulatora predykcyjnego');

ax = axes('Position', [0.45 0.3 0.5 0.4]);
uicontrol('Style', 'text', 'Position', [950 90 200 40], 'String', 'Funkcja zmiennej t: ', 'FontSize', 15, 'HorizontalAlignment', 'left');
stepPlot = uicontrol('Style', 'pushbutton', 'Position', [700 90 200 30], 'String', 'Odpowiedü skokowa');
funPlot = uicontrol('Style', 'pushbutton', 'Position', [700 50 200 30], 'String', 'Odpowiedü na zadany sygna≥');
fun = uicontrol('Style', 'edit', 'Position', [950 60 200 30], 'String', 't', 'FontSize', 15, 'HorizontalAlignment', 'right');

handles = struct('pidKp', pidKp, 'pidKi', pidKi, 'pidKd', pidKd, 'pidTf', pidTf, 'mpcTs', mpcTs, 'mpcP', mpcP, 'mpcM', mpcM, 'fun', fun);
set(pidSave, 'Callback', {@pidSaveCallback, handles});
set(pidLoad, 'Callback', {@pidReadFromFile, handles});
set(pidCheck, 'Callback', {@pidReview, handles, pid, sys});
set(mpcSave, 'Callback', {@mpcSaveCallback, handles});
set(mpcLoad, 'Callback', {@mpcReadFromFile, handles});
set(mpcCheck, 'Callback', {@mpcReview, handles, mpc});
set(stepPlot, 'Callback', {@stepResponse, handles, pid, mpc, sys});
set(funPlot, 'Callback', {@funResponse, handles, pid, mpc, sys});

function funResponse(~, ~, handles, pid, mpc, sys)
    funEdit = get(handles.fun, 'String');
    beginStr = '@(t)';
    funStr = strcat(beginStr, funEdit);
    funStr = strrep(funStr, '*', '.*');
    funStr = strrep(funStr, '/', './');
    funStr = strrep(funStr, '^', '.^');
    funStr = strrep(funStr, '..*', '.*');
    funStr = strrep(funStr, '../', './');
    funStr = strrep(funStr, '..^', '.^');
    funHandle = str2func(funStr);
    try
        funHandle(1);
    catch
        uiwait(msgbox('èle zdefiniowana funkcja zmiennej t.', 'B≥πd'));
        return
    end
    pidSaveCallback([], [], handles);
    mpcSaveCallback([], [], handles);
    pid.Kp = get(handles.pidKp, 'Value');
    pid.Ki = get(handles.pidKi, 'Value') ;
    pid.Kd = get(handles.pidKd, 'Value'); 
    pid.Tf = get(handles.pidTf, 'Value'); 
    mpc.Ts = get(handles.mpcTs, 'Value'); 
    mpc.PredictionHorizon = get(handles.mpcP, 'Value'); 
    mpc.ControlHorizon = get(handles.mpcM, 'Value');
    if mpc.Ts < 0.1
        t = 0:mpc.Ts:10;
    else
        t = 0:mpc.Ts:100 * mpc.Ts;
    end
    try
        samples = funHandle(t)';
        if numel(samples) == 1
            samples = samples .* ones(numel(t), 1);
        end
        [yPID, tPID] = lsim(feedback(pid * sys, 1), samples, t);
        [yMPC, tMPC] = sim(mpc, numel(t), samples);
    catch
        uiwait(msgbox('èle zdefiniowana funkcja zmiennej t.', 'B≥πd'));
        return
    end
    plot(tPID, yPID, tMPC, yMPC, t, samples);
    legend('Odpowiedü PID', 'Odpowiedü MPC', 'Sygna≥ zadany');
end

function pidReview(~, ~, handles, pid, sys)
    pidSaveCallback([], [], handles);
    pid.Kp = get(handles.pidKp, 'Value'); 
    pid.Ki = get(handles.pidKi, 'Value'); 
    pid.Kd = get(handles.pidKd, 'Value');
    pid.Tf = get(handles.pidTf, 'Value');
    model = feedback(pid * sys, 1);
    info = stepinfo(model);
    message = strcat({'Czas narastania: ',  'Czas ustawiania: ', 'Przeregulowanie: '; num2str(info.RiseTime), num2str(info.SettlingTime), num2str(info.Overshoot)});
    msgbox(message);
end

function mpcReview(~, ~, handles, mpc)
    mpcSaveCallback([], [], handles);
    mpc.Ts = get(handles.mpcTs, 'Value'); 
    mpc.PredictionHorizon = get(handles.mpcP, 'Value'); 
    mpc.ControlHorizon = get(handles.mpcM, 'Value');
    review(mpc);
end

function pidReadFromFile(~, ~, handles)
    try
        fileData = importdata("pid.txt", ' ');
    catch
        uiwait(msgbox('B≥πd otwierania pliku pid.txt - nie istnieje bπdü jest uszkodzony', 'B≥πd'));
        return
    end
    goodInput = 1;
    if size(fileData.data) == size(fileData.textdata)
        for i = (1:1:size(fileData.textdata))
            name = char(fileData.textdata(i));
            switch name
                case 'Kp'
                    set(handles.pidKp, 'String', fileData.data(i));
                case 'Ki'
                    set(handles.pidKi, 'String', fileData.data(i));
                case 'Kd'
                    set(handles.pidKd, 'String', fileData.data(i));
                case 'Tf'
                    set(handles.pidTf, 'String', fileData.data(i));
                otherwise
                    goodInput = 0;
                    break;
            end
        end
        if goodInput == 1
            pidSaveCallback([], [], handles);
        else
            uiwait(msgbox('B≥πd otwierania pliku pid.txt - nie istnieje bπdü jest uszkodzony', 'B≥πd'));
        end
    else
        uiwait(msgbox('B≥πd otwierania pliku pid.txt - nie istnieje bπdü jest uszkodzony', 'B≥πd'));
    end
end

function mpcReadFromFile(~, ~, handles)
    try
        fileData = importdata("mpc.txt", ' ');
    catch
        uiwait(msgbox('B≥πd otwierania pliku mpc.txt - nie istnieje bπdü jest uszkodzony', 'B≥πd'));
        return
    end
    goodInput = 1;
    if size(fileData.data) == size(fileData.textdata)
        for i = (1:1:size(fileData.textdata))
            name = char(fileData.textdata(i));
            switch name
                case 'Ts'
                    set(handles.mpcTs, 'String', fileData.data(i));
                case 'PredictionHorizon'
                    set(handles.mpcP, 'String', fileData.data(i));
                case 'ControlHorizon'
                    set(handles.mpcM, 'String', fileData.data(i));
                otherwise
                    goodInput = 0;
                    break;
            end
        end
        if goodInput == 1
            mpcSaveCallback([], [], handles);
        else
            uiwait(msgbox('B≥πd otwierania pliku mpc.txt - nie istnieje bπdü jest uszkodzony', 'B≥πd'));
        end
    else
        uiwait(msgbox('B≥πd otwierania pliku mpc.txt - nie istnieje bπdü jest uszkodzony', 'B≥πd'));
    end
end

function pidSaveCallback(~, ~, handles)
    oldKp = get(handles.pidKp, 'Value');
    oldKi = get(handles.pidKi, 'Value');
    oldKd = get(handles.pidKd, 'Value');
    oldTf = get(handles.pidTf, 'Value');
    newKp = str2double(strrep(get(handles.pidKp, 'String'), ',', '.'));
    newKi = str2double(strrep(get(handles.pidKi, 'String'), ',', '.'));
    newKd = str2double(strrep(get(handles.pidKd, 'String'), ',', '.'));
    newTf = str2double(strrep(get(handles.pidTf, 'String'), ',', '.'));
    if isequal(isfinite([newKp newKi newKd newTf]), [1 1 1 1]) && newTf >= 0 && isreal([newKp newKi newKd newTf]) == 1
        set(handles.pidKp, 'Value', newKp);
        set(handles.pidKp, 'String', newKp);
        set(handles.pidKi, 'Value', newKi);
        set(handles.pidKi, 'String', newKi);
        set(handles.pidKd, 'Value', newKd);
        set(handles.pidKd, 'String', newKd);
        set(handles.pidTf, 'Value', newTf);
        set(handles.pidTf, 'String', newTf);
    else
        set(handles.pidKp, 'String', oldKp);
        set(handles.pidKi, 'String', oldKi);
        set(handles.pidKd, 'String', oldKd);
        set(handles.pidTf, 'String', oldTf);
        uiwait(msgbox('Podano niew≥aúciwe parametry kontrolera PID - przywrÛcono poprzednie wartoúci', 'B≥πd'));
    end
end

function mpcSaveCallback(~, ~, handles)
    oldTs = get(handles.mpcTs, 'Value');
    oldP = get(handles.mpcP, 'Value');
    oldM = get(handles.mpcM, 'Value');
    newTs = str2double(strrep(get(handles.mpcTs, 'String'), ',', '.'));
    newP = str2double(strrep(get(handles.mpcP, 'String'), ',', '.'));
    newM = str2double(strrep(get(handles.mpcM, 'String'), ',', '.'));
    positiveInt= @(n) (rem(n,1) == 0) & (n > 0);
    if isequal(isfinite([newTs newP newM]), [1 1 1]) && newTs > 0 && isequal([positiveInt(newP) positiveInt(newM)], [1 1]) && newP >= newM && isreal([newTs newP newM]) == 1
        set(handles.mpcTs, 'Value', newTs);
        set(handles.mpcTs, 'String', newTs);
        set(handles.mpcP, 'Value', newP);
        set(handles.mpcP, 'String', newP);
        set(handles.mpcM, 'Value', newM);
        set(handles.mpcM, 'String', newM);
    else
        set(handles.mpcTs, 'String', oldTs);
        set(handles.mpcP, 'String', oldP);
        set(handles.mpcM, 'String', oldM);
        uiwait(msgbox('Podano niew≥aúciwe parametry kontrolera MPC - przywrÛcono poprzednie wartoúci', 'B≥πd'));
    end
end

function stepResponse(~, ~, handles, pid, mpc, sys)
    pidSaveCallback([], [], handles);
    mpcSaveCallback([], [], handles);
    pid.Kp = get(handles.pidKp, 'Value');
    pid.Ki = get(handles.pidKi, 'Value') ;
    pid.Kd = get(handles.pidKd, 'Value'); 
    pid.Tf = get(handles.pidTf, 'Value'); 
    mpc.Ts = get(handles.mpcTs, 'Value'); 
    mpc.PredictionHorizon = get(handles.mpcP, 'Value'); 
    mpc.ControlHorizon = get(handles.mpcM, 'Value');
    [yPID, tPID] = step(feedback(pid * sys, 1));
    numOfIters = ceil(max(tPID) / mpc.Ts) + 1;
    [yMPC, tMPC] = sim(mpc, numOfIters, 1.0);
    plot(tPID, yPID, tMPC, yMPC, tPID, ones(size(tPID)));
    legend('Odpowiedü PID', 'Odpowiedü MPC', 'Sygna≥ zadany');
end