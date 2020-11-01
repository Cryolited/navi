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

dt = 1 / Res.File.Fs; % ����� �� ������� 
shiftCheck = 2;
NumOfNeededSamples = CALen;
    % ������ ���������
        fprintf('%s ������� ���������\n', datestr(now));
    for k = 1:1 %1:Res.Search.NumSats
        % ������ ���������
            fprintf('%s     ������� �������� �%02d (%d �� %d) ...\n', ...
                datestr(now), Res.Search.SatNums(k), k, ...
                Res.Search.NumSats);
            NumOfShiftedSamples = Res.Search.SamplesShifts(k);
            freq = Res.Search.FreqShifts(k);
            CACode = GenCACode(Res.Search.SatNums(k));
            CACode2 = repelem(CACode,Res.File.R);
            shift = 0; % ����� ��������
            %CorAbs = zeros( NumCFreqs, CALen ); % ���������� ��� ����������            
            for m=1:1e4+1 % 
                Signal = ReadSignalFromFile(Res.File, NumOfShiftedSamples + CALen*(m-1) - shiftCheck + shift, NumOfNeededSamples+4);
                %Signal = ReadSignalFromFile(Res.File, (m-1)*(2046*2-1+1), 2046*2-1);
                doppler = exp(1j*2*pi*-freq*[1:length(Signal)] * dt);
                SignalM = Signal .* doppler;                
                Cor3 = conv(SignalM,fliplr(CACode2), 'valid');
                [~, IndMax] = max(abs(Cor3));
                shift = shift + IndMax - shiftCheck - 1;  
                phasCA(m) = angle(Cor3(IndMax)) / pi;
                absCor(m) = abs(Cor3(IndMax));
                shiftCA(m) = shift;
                CorVals(m) = Cor3(IndMax);
            end
                
        % ������ ���������
            fprintf('%s         ���������.\n', datestr(now));
    end
    % ������� ����� ���� � ������������ � Res
        Res.Track = Track;

    % ������ ���������
        fprintf('%s     ���������.\n', datestr(now));    

%% �������� ����� ������� - ������� �������������

for k = 1 : 1 %Res.Search.NumSats
    
    Mult = CorVals(2:end) .* conj(CorVals(1:end-1));
    AngleMult = angle(Mult)/pi;
    figure; 
    plot(AngleMult);
    
    MultCor = abs(sum(reshape(Mult(1:end),20,500),2));
    figure; 
    plot(MultCor);    

end


