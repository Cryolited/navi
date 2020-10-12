function Res = P20_NonCohTrackSatsAndBitSync(inRes, Params)
%
% ������� �������������� �������� ��������� � ������� �������������
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
        'SamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',       {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������ cell-�������� SamplesShifts � CorVals �������� ��������
    %   1xN, ��� N - ���������� �������� CA-���� ���������������� ��������,
    %   ��������� � �����-������ (N ����� ���� ������ ��� ������
    %   ���������).
    % ������ ������� ������� SamplesShifts{k} - ���������� ��������,
    %   ������� ���� ���������� � �����-������ �� ������ ����������������
    %   ������� CA-����.
    % ������ ������� ������� CorVals{k} - ����������� �������� ����������
    %   ����� �������, ���������� ��������������� ������ CA-����, � �������
    %   ��������.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % ������ ������� ������� CAShifts - ���������� �������� CA-����,
    %   ������� ���� ���������� �� ������ ����.
    % ������ ������ ������� Cors - ����������, �� ������� �������� �������
    %   ������������ ������� �������������.

%% ��������� ����������
    % ���������� �������� CA-���� ����� ��������� ��������������� ��
    % ������� (NumCA2NextSync >= 1, NumCA2NextSync = 1 - ������������� ���
    % ������� CA-����)
        NumCA2NextSync = Params.P20_NonCohTrackSatsAndBitSync.NumCA2NextSync;

    % �������� ���������� �������������� �������� CA-����, ������������ ���
    % ������������� �� �������
        HalfNumCA4Sync = Params.P20_NonCohTrackSatsAndBitSync.HalfNumCA4Sync;

    % ���������� ����������� �������� ��������/������ ������������� ��
    % �������
        HalfCorLen = Params.P20_NonCohTrackSatsAndBitSync.HalfCorLen;

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        NumCA2Disp = Params.P20_NonCohTrackSatsAndBitSync.NumCA2Disp;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        MaxNumCA2Process = Params.P20_NonCohTrackSatsAndBitSync.MaxNumCA2Process;

    % ���������� ���, ������������ ��� ������� �������������
        NBits4Sync = Params.P20_NonCohTrackSatsAndBitSync.NBits4Sync;

%% ���������� ����������
    Track.NumCA2NextSync   = NumCA2NextSync;
    Track.HalfNumCA4Sync   = HalfNumCA4Sync;
    Track.HalfCorLen       = HalfCorLen;
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% ���ר� ����������
    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

%% �������� ����� ������� - �������
df = 50;
dt = 2; % ����� �� ������� 
NumOfNeededSamples = CALen + 4;
    % ������ ���������
        fprintf('%s ������� ���������\n', datestr(now));
    for k = 3:4 %1:Res.Search.NumSats
        % ������ ���������
            fprintf('%s     ������� �������� �%02d (%d �� %d) ...\n', ...
                datestr(now), Res.Search.SatNums(k), k, ...
                Res.Search.NumSats);
            NumOfShiftedSamples = Res.Search.SamplesShifts(k);
            freq = Res.Search.FreqShifts(k);
            CACode = GenCACode(k,1);
            CACode2 = repelem(CACode,Res.File.R);
            %CorAbs = zeros( NumCFreqs, CALen ); % ���������� ��� ����������            
            for m=1:50
                Signal = ReadSignalFromFile(Res.File, NumOfShiftedSamples-2 + CALen*(m-1), NumOfNeededSamples);
                %Signal = ReadSignalFromFile(Res.File, (m-1)*(2046*2-1+1), 2046*2-1);
                doppler = exp(1j*2*pi*-freq*[1:length(Signal)] * dt);
                SignalM = Signal .* doppler;                
                Cor3(m,:) = conv(SignalM,fliplr(CACode2), 'valid');       
            end
                
        % ������ ���������
            fprintf('%s         ���������.\n', datestr(now));
    end
    % ������� ����� ���� � ������������ � Res
        Res.Track = Track;

    % ������ ���������
        fprintf('%s     ���������.\n', datestr(now));    

%% �������� ����� ������� - ������� �������������



