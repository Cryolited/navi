function Res = P10_NonCohSearchSats(inRes, Params)
%
% ������� ������������ ������ ��������� � �����-������
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
    Search = struct( ...
        'NumSats',       0, ... % ������, ���������� ��������� ���������
        'SatNums',       [], ... % ������ 1�NumSats � �������� ���������
            ... % ���������
        'SamplesShifts', [], ... % ������ 1�NumSats, ������ ������� -
            ... % ���������� ��������, ������� ����� ���������� � �����-
            ... % ������ �� ������ ������� ������� CA-���� ����������������
            ... % ��������
        'FreqShifts',    [], ... % ������ 1�NumSats �� ���������� ���������
            ... % ������� ��������� ��������� � ��
        'CorVals',       [], ... % ������ 1�NumSats ������������ ��������
            ... % ����� �������������� ������� ������������� �� �������
            ... % ��������, �� ������� ���� ������� ��������
        'AllCorVals',    zeros(1, 32) ... % ������ ������������ ��������
            ... % ���� ����������� ��� �������
    );

%% ��������� ����������
    % ���������� ��������, ����������� ��� �����������.
        NumCA2Search = Params.P10_NonCohSearchSats.NumCA2Search;

    % ������ ����������� ������ ������������� ����������, ��
        CentralFreqs = Params.P10_NonCohSearchSats.CentralFreqs;

    % ����� �����������
        SearchThreshold = Params.P10_NonCohSearchSats.SearchThreshold;

%% ���������� ����������
    Search.NumCA2Search    = NumCA2Search;
    Search.CentralFreqs    = CentralFreqs;
    Search.SearchThreshold = SearchThreshold;

%% ���ר� ����������
    % ���������� ��������������� ��������� ����������
        NumCFreqs = length(CentralFreqs);

    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

%% �������� ����� �������
 
      
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



end