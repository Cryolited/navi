function Res = P30_NonCohDemodSatsSigs(inRes, Params)
%
% Функция некогерентной демодуляции сигналов спутников
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
    Demod = struct( ...
        'Bits', {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждый элемент cell-массива Bits - массив 4хN значений 0/1, где
    %   N - количество демодулированных бит.

%% УСТАНОВКА ПАРАМЕТРОВ

%% РАСЧЁТ ПАРАМЕТРОВ
    % Количество периодов CA-кода, приходящихся на один бит
        CAPerBit = 20;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ
% load('Rate2.mat');
    for k = 1: Res.Search.NumSats % спутник №1
    CAShift = Res.BitSync.CAShifts(k);
    CorVals = Res.Track.CorVals{k}(CAShift+1:end);% Пропускаем отчеты до первого бита 
    
%     % 1 Производная
%     dCorVals = CorVals(2:end) .* conj(CorVals(1:end-1)); % разность фаз между соседними отчетами
%     figure
%     plot(angle(dCorVals)/pi); % Тут увидим, что фаза "плывет"

%     % Вторая производная
%     ddCorVals = dCorVals(2:end) .* conj(dCorVals(1:end-1)); % Еще разность, чтобы зафиксировать изменение фазы
%     figure
%     plot(angle(ddCorVals)/pi, '.'); % по порогу пи/2 можно принять решение
     %plot(real(ddCorVals)); % по >< 0 можно принять решение, без взятия фазы
% ======= Выше - слабый ОСШ, значит делаем накопление
    L = length(CorVals);
    NBits = floor(L/CAPerBit); % Обрезаем до кол-ва бит
    CorVals = CorVals(1:NBits*CAPerBit); % берем отчеты, кратные кол-ву бит
     % 1 Производная
    dCorVals20 = CorVals(21:end) .* conj(CorVals(1:end-20));
%    figure
%    plot(angle(dCorVals20)/pi, '.'); % Набег фазы стал больше, тк разность между соседними 20 отчетами  
     % Само Накопление
    IntdCorVals20 = sum(reshape(dCorVals20, 20, []), 1); % Разбиваем на блоки по 20 эелементов, в каждом блоке фаза одинаковая
%     figure
%     plot(angle(IntdCorVals20)/pi, '.'); % Накопили, но фаза еще "плывет"
     % Вторая производная
    ddCorVals20 = IntdCorVals20(2:end) .* conj(IntdCorVals20(1:end-1)); 
%     figure
%     plot(angle(ddCorVals20)/pi, '.'); 
    
    ddBits = real(ddCorVals20)<0; % Жесткие решения
    dBits = [mod(cumsum([0 ,ddBits]), 2) ; mod(cumsum([1 ,ddBits]), 2)] ; % два решения при первом интегрировании
    Bits = [mod(cumsum([[0;0] ,dBits],2), 2) ; mod(cumsum([[1;1] ,dBits],2), 2)] ; % 4 решения при 2 интегрировании
    Demod.Bits{k,1} = Bits([1 2],:); % тк другие 2 повторяются
    end
    Res.Demod = Demod;
end
    
    
  