  function Res = P20_CohTrackSatsAndBitSync(inRes, Params)
%
% ������� ������������ �������� ��������� � ������� �������������
%
% ������� ����������
%   inRes - ��������� � ������������ ������, ����������� � Main;
%
% �������� ����������
%   Res - ���������, ������� ���������� �� inRes ����������� ������ ����,
%       �������� �������� ���� ���� � ����.

% �������������� �����������
    Res = inRes;

%% ������������� ����������
    Track = struct( ...
        'SamplesShifts',     {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',           {cell(Res.Search.NumSats, 1)}, ...
        'HardSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'FineSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'EPLCorVals',        {cell(Res.Search.NumSats, 1)}, ...
        'DLL',               {cell(Res.Search.NumSats, 1)}, ...
        'FPLL',              {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������ cell-�������� SamplesShifts, CorVals, HardSamplesShifts
    %   FineSamplesShifts �������� �������� 1xN, ��� N - ����������
    %   �������� CA-���� ���������������� ��������, ��������� � �����-
    %   ������ (N ����� ���� ������ ��� ������ ���������).
    % ������ ������� ������� SamplesShifts{k} - ������� ����������
    %   ��������, ������� ���� ���������� � �����-������ �� ������
    %   ���������������� ������� CA-����.
    % ������ ������� ������� CorVals{k} - ����������� �������� ����������
    %   ����� �������, ���������� ��������������� ������ CA-����, � �������
    %   ��������.
    % ������ ������� �������� HardSamplesShifts{k}, FineSamplesShifts{k} -
    %   �������������� ������� � ����� ����� �������� SamplesShifts{k}.
    % ������ ������ cell-������� EPLCorVals �������� �������� 3xN ��������
    %   Early, Promt � Late ����������. ��� ����: SamplesShifts{k} =
    %   EPLCorVals{k}(2, :).
    % DLL, FPLL - ��� ������������� ���� ���� � �������-���� �������.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % ������ ������� ������� CAShifts - ���������� �������� CA-����,
    %   ������� ���� ���������� �� ������ ����.
    % ������ ������ ������� Cors - ����������, �� ������� �������� �������
    %   ������������ ������� �������������.

%% ��������� ����������
    % ������� ��������
        DLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.DLL.FilterOrder;
        FPLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterOrder;
        
    % � DLL � FPLL ����� ��������� ������� ������ ��� ������� �� ��� �����
    % ����������
        % ������ ��������
            DLL.FilterBands  = Params.P20_CohTrackSatsAndBitSync.DLL.FilterBands;
            FPLL.FilterBands = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterBands;
            
        % ���������� �������� ���������� ��� ����������
            DLL.NumsIntCA  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsIntCA;
            FPLL.NumsIntCA = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsIntCA;

	% ��������� ���������� �������� CA-����, ����������� ��� ��������
	% ������������� �������� ����� ����������� DLL � FPLL. ��������
	% �������� �� �������� integrate and dump
        DLL.NumsCA2CheckState  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsCA2CheckState;
        FPLL.NumsCA2CheckState = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsCA2CheckState;
        
    % ��������� �������� ��� �������� ����� �����������
    % ���� �������� > HiTr, �� ��������� � ��������� (����� ���������)
    %   ���������
    % ���� �������� < LoTr, �� ��������� � ���������� (�����
    %   ��������������)���������
        DLL.HiTr = Params.P20_CohTrackSatsAndBitSync.DLL.HiTr;
        DLL.LoTr = Params.P20_CohTrackSatsAndBitSync.DLL.LoTr;
        
        FPLL.HiTr = Params.P20_CohTrackSatsAndBitSync.FPLL.HiTr;
        FPLL.LoTr = Params.P20_CohTrackSatsAndBitSync.FPLL.LoTr;

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        NumCA2Disp = Params.P20_CohTrackSatsAndBitSync.NumCA2Disp;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        MaxNumCA2Process = Params.P20_CohTrackSatsAndBitSync.MaxNumCA2Process;

    % ���������� ���, ������������ ��� ������� �������������
        NBits4Sync = Params.P20_CohTrackSatsAndBitSync.NBits4Sync;

%% ���������� ����������
    % Track.FPLL = FPLL; % �� �����, ��� ��� �� ����� ����� ������� �
    % Track.DLL = DLL;   % �����
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% ���ר� ����������
    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

    % ������������ CA-����, ��
        TCA = 10^-3;

%% �������� ����� ������� - ������� � ������� �������������

df = 50;
f = 3250 : df : 3750; % ����� �� �������
dt = 2; % ����� �� ������� 



      NumOfShiftedSamples = 0;
      NumOfNeededSamples = 2*CALen-1;
      NumSatellite = 3; %32
      drawThreshold = 3; % ����� ��������� ��������, ���� ��� ����(Search.SearchThreshold)
      drawFlag = 0; % ���� ���������
      nonCohFlag = 1; % ���� �����. ���.
      
    if (nonCohFlag == 1)
        NumRepeat = 10; % ������
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
    CorAbs = zeros( NumCFreqs, CALen ); % ���������� ��� ����������
    CorAbs2 = zeros( NumCFreqs, CALen );    
    for k=1:NumRepeat*2 % accumulation twice!! 
        NumOfShiftedSamples = (k-1)*(NumOfNeededSamples+1); % +1 ���� �������� �����
        Signal = ReadSignalFromFile(Res.File, NumOfShiftedSamples, NumOfNeededSamples);
        for m=1:NumCFreqs
            freq = CentralFreqs(m);
            doppler = exp(1j*2*pi*freq*[1:length(CACode2)] * dt);
            CACodeM = CACode2 .* doppler;                
            Cor3(m,:) = conv(Signal,fliplr(CACodeM), 'valid');       
        end
        %disp([ max(max(abs(Cor3))) ,  mean(mean(abs(Cor3))), max(max(abs(Cor3)))/mean(mean(abs(Cor3)))]);
        if k <= NumRepeat
            CorAbs = CorAbs + abs(Cor3); % ���������� 1 !!
        else
            CorAbs2 = CorAbs2 + abs(Cor3); % ���������� 2 !!
        end
        
    end
    
    if (max(max(CorAbs)) > max(max(CorAbs2))) % � ���� �������� ����
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



