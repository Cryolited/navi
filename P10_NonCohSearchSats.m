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
        'NumSats',       [], ... % ������, ���������� ��������� ���������
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
%       inFile.Name = 'Z:\������������ ���������\���\MATLAB\Signals\30_08_2018__19_38_33_x02_1ch_16b_15pos_90000ms.dat';
%       inFile.HeadLenInBytes = 0;
%       inFile.NumOfChannels =1;
%       inFile.ChanNum = 0;
%       inFile.DataType = 'int16';
%       inFile.Fs0= 2046e3;
%       inFile.dF = 0 ;
%       inFile.FsDown = 1;
%       inFile.FsUp = 1;
      
      
      NumOfShiftedSamples = 0;
      NumOfNeededSamples = 2*CALen-1;
      NumSatellite = 32;
    Signal = ReadSignalFromFile(Res.File, NumOfShiftedSamples, NumOfNeededSamples);
    Cor3 = zeros( NumCFreqs, CALen  );
    dt = 1 / Res.File.Fs;
for n=1:NumSatellite
    CACode = GenCACode(n,1);
    CACode2 = repelem(CACode,Res.File.R);
    for m=1:NumCFreqs
        freq = CentralFreqs(m);
        doppler = exp(1j*2*pi*freq*[1:length(CACode2)] * dt);
        CACodeM = CACode2 .* doppler;       
        for k=1:NumCFreqs          
            Cor3(k,:) = conv(Signal,fliplr(CACodeM), 'valid');
        end
         
        
    end
    
    
end
   mesh(abs(Cor3)); 

end