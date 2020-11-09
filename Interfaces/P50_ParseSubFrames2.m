function Res = P50_ParseSubFrames(inRes, Params) %#ok<INUSD>
%
% Функция демодуляции сигналов спутников
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
    SatsData = struct( ...
        'isSat2Use', zeros(1, Res.Search.NumSats), ...
        'TLM', {cell(Res.Search.NumSats, 1)}, ...
        'HOW', {cell(Res.Search.NumSats, 1)}, ...
        'SF1', {cell(Res.Search.NumSats, 1)}, ...
        'SF2', {cell(Res.Search.NumSats, 1)}, ...
        'SF3', {cell(Res.Search.NumSats, 1)}, ...
        'SF4', {cell(Res.Search.NumSats, 1)}, ...
        'SF5', {cell(Res.Search.NumSats, 1)} ...
    );
    % Элементами всех cell-массивов (TLM, HOW, SF1, SF2, SF3, SF4, SF5)
    % являются структуры-массивы (1хN) с результатами парсинга, где N -
    % количество обработанных для спутника подкадров. Если какое то поле не
    % расшифровано из-за того, что не сошлось CRC, то его значение должно
    % быть установлено в nan. isSat2Use - массив флагов, указывающих,
    % было ли расшифровано хотя бы одно поле HOW.TOW_Count_Message, т.е.
    % имеет ли смысл в дальнейшем изучать содержимое подкадров (конечно,
    % isSat2Use = 0, если у этого спутника isSubFrameSync = 0).

%% УСТАНОВКА ПАРАМЕТРОВ

%% РАСЧЁТ ПАРАМЕТРОВ

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ С УСПЕШНОЙ
% ПОДКАДРОВОЙ СИНХРОНИЗАЦИЕЙ
% load('Rate2.mat');

AllWords = Res.SubFrames.Words;

SatNum = 1;
Words = AllWords{SatNum};
%NumW = 4;
for NumW = 1:14
TLM(NumW) = ParseTLM(Words{NumW,1}); %  for {:14,1}
HOW(NumW) = ParseHOW(Words{NumW,2}); %  for {:14,2}
switch HOW(NumW).Subframe_ID
    case 1
        SF1(NumW) = ParseSF1(Words(NumW,:)); % if NumW = 2; Круглые() позволяют выделить строку cell
    case 2
        SF2(NumW) = ParseSF2(Words(NumW,:)); % if NumW = 3;
    case 3
        SF3(NumW) = ParseSF3(Words(NumW,:)); % if NumW = 4;
end
end
end

function [Bits, isCRC] = Words2BitFrame(Words)
% Из (1х8) cell-массива Words составим кадр, т.е. добавим нулевые биты CRC
% и нулевые первые два слова. Это удобно для анализа кода по спецификации.
% Также составим массив флагов, указывающих на то, сошлось CRC в конкретном
% слове или нет

end

function Data = ParseSF1(Words)
%
% Парсинг подкадра №1
SF1Word3 = Words{3}; %  for {14,}
Data.WeekNumber = bi2de(SF1Word3(1:10), 'left-msb');
if (SF1Word3(12))
    Data.CodesOnL2 = 'P code ON'; % 2 bits must be 0,1
else
    Data.CodesOnL2 = 'C/A code ON'; % 1,0
end 
Data.URA  = bi2de(SF1Word3(13:16), 'left-msb'); % 4 bits
Data.URA_in_meters = 0; % IAURANED = URANED0 + URANED1 (t - top + 604,800*(WN - WNop))
%SV_Health = bi2de(SF1Word3(17:22), 'left-msb'); % 6 bits
if (SF1Word3(17))
    Data.SV_Health_Summary = 'some or all NAV data are bad'; 
else
    Data.SV_Health_Summary = 'All NAV data are OK'; % 1 bit
end 
if (sum(SF1Word3(18:22)))
    Data.SV_Health = 'Signals not OK'; 
else
    Data.SV_Health = 'All Signals OK'; % 6 bits
end 
IODC1 = SF1Word3(23:24); % 2 Major bits
IODC2 = Words{8}(1:8); % 8 Least bits
Data.IODC = bi2de([IODC1 IODC2], 'left-msb'); % 10 Total bits

if (Words{4}(1))
    Data.L2_P_Data_Flag = '??'; 
else
    Data.L2_P_Data_Flag = 'Data ON on the L2 P-code'; % 1 bit
end 
Data.T_GD = comp2de(Words{7}(17:24)) * 2^-31;


Data.t_oc = bi2de(Words{8}(9:24), 'left-msb') * 2^4;

Data.a_f2 = comp2de(Words{9}(1:8)) * 2^-55;
Data.a_f1 = comp2de(Words{9}(9:24)) * 2^-43 ;
Data.a_f0 = comp2de(Words{10}(1:22)) * 2^-31;
end

function Data = ParseSF2(Words)
%
% Парсинг подкадра №2
Data.IODE = bi2de(Words{3}(1:8), 'left-msb'); % 8 bits
Data.C_rs = comp2de(Words{3}(9:24)) * 2^-5 ; % 16 bits
Data.Delta_n = comp2de(Words{4}(1:16)) * 2^-43; % comp
Data.M_0 = comp2de([ Words{4}(17:24) Words{5}(1:24)]) * 2^-31; %comp
Data.C_uc = comp2de(Words{6}(1:16)) * 2^-29; % comp
Data.e = bi2de([ Words{6}(17:24) Words{7}(1:24)],'left-msb') * 2^-33; 
Data.C_us = comp2de(Words{8}(1:16)) * 2^-29; % comp

Data.sqrtA = bi2de([ Words{8}(17:24) Words{9}(1:24)],'left-msb') * 2^-19; 
Data.t_oe = bi2de(Words{10}(1:16),'left-msb') * 2^4; 
Data.Fit_Interval_Flag = Words{10}(17);
Data.AODO = bi2de(Words{10}(18:22),'left-msb')*900 ; 

end

function Data = ParseSF3(Words)
%
% Парсинг подкадра №3
Data.C_ic = comp2de(Words{3}(1:16)) * 2^-29; % comp
Data.Omega_0 = comp2de([ Words{3}(17:24) Words{4}(1:24)]) * 2^-31; %comp
Data.C_is = comp2de(Words{5}(1:16)) * 2^-29; % comp
Data.i_0 = comp2de([ Words{5}(17:24) Words{6}(1:24)]) * 2^-31 ; %comp
Data.C_rc = comp2de(Words{7}(1:16)) * 2^-5; % comp
Data.omega = comp2de([ Words{7}(17:24) Words{8}(1:24)]) * 2^-31; %comp

Data.DOmega = comp2de(Words{9}(1:24)) * 2^-43 ; % comp
Data.IODE = bi2de(Words{10}(1:8),'left-msb') ;
Data.IDOT = comp2de(Words{10}(9:22)) * 2^-43 ; % comp
end

function Data = ParseSF4(Words)
%
% Парсинг подкадра №4 - реализован только для (SV_Page_ID = 56)

end

function Data = ParseSF5(Words)
%
% Парсинг подкадра №5

% Парсинг не реализован

end

function Data = ParseTLM(Word)
%
% Парсинг слова TLM
Data.Preamble =                  bi2de(Word(1:8), 'left-msb');
Data.TLM_Message =               bi2de(Word(9:22),'left-msb');
Data.TLM_Integrity_Status_Flag = bi2de(Word(23),  'left-msb');
end

function Data = ParseHOW(Word)
%
% Парсинг слова HOW
Data.TOW_Count_Message =         bi2de(Word(1:17), 'left-msb');
Data.Alert_Flag =                bi2de(Word(18),   'left-msb');
Data.Anti_Spoof_Flag =           bi2de(Word(19),   'left-msb');
Data.Subframe_ID =               bi2de(Word(20:22),'left-msb');
end


%%
function Out = comp2de(In)
%
% Функция перевода двоичного дополнительного кода в десятичное число
if (In(1) == 1)    
    Invert = bi2de(In, 'left-msb') -1;
    Invert2 = de2bi(Invert, 'left-msb');
    Invert2(1:end) = Invert2(1:end)~=1;
    Out = -1 * (bi2de(Invert2, 'left-msb') ) ;    
else
    Out = bi2de(In, 'left-msb') ; 
end

end