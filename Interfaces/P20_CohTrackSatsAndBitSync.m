  function Res = P20_CohTrackSatsAndBitSync(inRes, Params)
%
% Функция когерентного трекинга спутников и битовой синхронизации
%
% Входные переменные
%   inRes - структура с результатами модели, объявленная в Main;
%
% Выходные переменные
%   Res - структура, которая отличается от inRes добавлением нового поля,
%       описание которого дано ниже в коде.

% Пересохранение результатов
    Res = inRes;

%% ИНИЦИАЛИЗАЦИЯ РЕЗУЛЬТАТА
    Track = struct( ...
        'SamplesShifts',     {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',           {cell(Res.Search.NumSats, 1)}, ...
        'HardSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'FineSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'EPLCorVals',        {cell(Res.Search.NumSats, 1)}, ...
        'DLL',               {cell(Res.Search.NumSats, 1)}, ...
        'FPLL',              {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждая ячейка cell-массивов SamplesShifts, CorVals, HardSamplesShifts
    %   FineSamplesShifts является массивом 1xN, где N - количество
    %   периодов CA-кода соответствующего спутника, найденных в файле-
    %   записи (N может быть разным для разных спутников).
    % Каждый элемент массива SamplesShifts{k} - дробное количество
    %   отсчётов, которые надо пропустить в файле-записи до начала
    %   соответствующего периода CA-кода.
    % Каждый элемент массива CorVals{k} - комплексное значение корреляции
    %   части сигнала, содержащей соответствующий период CA-кода, с опорным
    %   сигналом.
    % Каждый элемент массивов HardSamplesShifts{k}, FineSamplesShifts{k} -
    %   соответственно дробная и целая части значений SamplesShifts{k}.
    % Каждая ячейка cell-массива EPLCorVals является массивом 3xN значений
    %   Early, Promt и Late корреляций. При этом: SamplesShifts{k} =
    %   EPLCorVals{k}(2, :).
    % DLL, FPLL - лог сопровождения фазы кода и частоты-фазы сигнала.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % Каждый элемент массива CAShifts - количество периодов CA-кода,
    %   которые надо пропустить до начала бита.
    % Каждая строка массива Cors - корреляции, по позиции минимума которых
    %   определяется битовая синхронизация.

%% УСТАНОВКА ПАРАМЕТРОВ
    % Порядок фильтров
        DLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.DLL.FilterOrder;
        FPLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterOrder;
        
    % И DLL и FPLL имеют несколько режимов работы для каждого из них нужно
    % определить
        % Полосы фильтров
            DLL.FilterBands  = Params.P20_CohTrackSatsAndBitSync.DLL.FilterBands;
            FPLL.FilterBands = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterBands;
            
        % Количество периодов накопления для фильтрации
            DLL.NumsIntCA  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsIntCA;
            FPLL.NumsIntCA = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsIntCA;

	% Определим количество периодов CA-кода, учитываемых для проверки
	% необходимости перехода между состояниями DLL и FPLL. Проверка
	% работает по принципу integrate and dump
        DLL.NumsCA2CheckState  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsCA2CheckState;
        FPLL.NumsCA2CheckState = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsCA2CheckState;
        
    % Граничные значения для перехода между состояниями
    % Если значение > HiTr, то переходим в следующее (более робастное)
    %   состояние
    % Если значение < LoTr, то переходим в предыдущее (более
    %   чувствительное)состояние
        DLL.HiTr = Params.P20_CohTrackSatsAndBitSync.DLL.HiTr;
        DLL.LoTr = Params.P20_CohTrackSatsAndBitSync.DLL.LoTr;
        
        FPLL.HiTr = Params.P20_CohTrackSatsAndBitSync.FPLL.HiTr;
        FPLL.LoTr = Params.P20_CohTrackSatsAndBitSync.FPLL.LoTr;

    % Период, с которым производится отображение числа обработанных
    % CA-кодов
        NumCA2Disp = Params.P20_CohTrackSatsAndBitSync.NumCA2Disp;

    % Максимальное число обрабатываемых CA-кодов (inf - до конца файла!)
        MaxNumCA2Process = Params.P20_CohTrackSatsAndBitSync.MaxNumCA2Process;

    % Количество бит, используемых для битовой синхронизации
        NBits4Sync = Params.P20_CohTrackSatsAndBitSync.NBits4Sync;

%% СОХРАНЕНИЕ ПАРАМЕТРОВ
    % Track.FPLL = FPLL; % не нужно, так как всё равно будет сделано в
    % Track.DLL = DLL;   % конце
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Длина CA-кода с учётом частоты дискретизации
        CALen = 1023 * Res.File.R;

    % Количество периодов CA-кода, приходящихся на один бит
        CAPerBit = 20;

    % Длительность CA-кода, мс
        TCA = 10^-3;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ТРЕКИНГ И БИТОВАЯ СИНХРОНИЗАЦИЯ

df = 50;
f = 3250 : df : 3750; % сдвиг по частоте
dt = 2; % сдвиг по отчетам 



      NumOfShiftedSamples = 0;
      NumOfNeededSamples = 2*CALen-1;
      NumSatellite = 3; %32
      drawThreshold = 3; % Порог отрисовки значений, пока что свой(Search.SearchThreshold)
      drawFlag = 0; % Флаг отрисовки
      nonCohFlag = 1; % Флаг неког. обр.
      
    if (nonCohFlag == 1)
        NumRepeat = 10; % Опасно
    else
        NumRepeat = 1;
    end
    Cor3 = zeros( NumCFreqs, CALen );
    dt = 1 / Res.File.Fs;
    LastSat = 0;

for n=1:NumSatellite
    tic
    CACode = GenCACode(n,1);
    CACode2 = repelem(CACode,Res.File.R);
    CorAbs = zeros( NumCFreqs, CALen ); % обновление для накопления
    CorAbs2 = zeros( NumCFreqs, CALen );    
    for k=1:NumRepeat*2 % accumulation twice!! 
        NumOfShiftedSamples = (k-1)*(NumOfNeededSamples+1); % +1 чтоб совпадал сдвиг
        Signal = ReadSignalFromFile(Res.File, NumOfShiftedSamples, NumOfNeededSamples);
        for m=1:NumCFreqs
            freq = CentralFreqs(m);
            doppler = exp(1j*2*pi*freq*[1:length(CACode2)] * dt);
            CACodeM = CACode2 .* doppler;                
            Cor3(m,:) = conv(Signal,fliplr(CACodeM), 'valid');       
        end
        %disp([ max(max(abs(Cor3))) ,  mean(mean(abs(Cor3))), max(max(abs(Cor3)))/mean(mean(abs(Cor3)))]);
        if k <= NumRepeat
            CorAbs = CorAbs + abs(Cor3); % накопление 1 !!
        else
            CorAbs2 = CorAbs2 + abs(Cor3); % накопление 2 !!
        end
        
    end
    
    if (max(max(CorAbs)) > max(max(CorAbs2))) % У кого максимум выше
        MaxVal = max(max(CorAbs));
        CorVal = MaxVal/mean(mean(CorAbs));
    else
        CorAbs = CorAbs2;
        MaxVal = max(max(CorAbs2));
        CorVal = MaxVal/mean(mean(CorAbs2));
    end
    if ( CorVal > drawThreshold && LastSat ~= n )
        if ( drawFlag == 1 )
            figure();
            mesh(CorAbs);
        end   
        Search.NumSats = Search.NumSats + 1; 
        Search.CorVals(end+1) = CorVal;
        Search.SatNums(end+1) = n;
        
        [MaxFreq,MaxCA] = find(CorAbs==MaxVal);
        Search.FreqShifts(end+1) = CentralFreqs(MaxFreq);
        Search.SamplesShifts(end+1) = mod(MaxCA , CALen);
        LastSat = n;
    end
    Search.AllCorVals(n) = MaxVal;
    toc
end



