function [Signal, File] = ReadSignalFromFile(inFile, ...
    NumOfShiftedSamples, NumOfNeededSamples)
%
% ������� ������������ ���������� ������� �� �����. ��� �������������
% ����������� ����������������� �������. �������� ����������� � ���, ���
% �������� NumOfShiftedSamples � NumOfNeededSamples ���������� ��� ���
% ������� ����� �����������������, �.�. ������������ ����� �� ������������
% � ��������� ������� ������� ��������, ����������� �� ����� ��� ���������
% ������� �������� � ���������������������� ����� �������.
%
% ������� ����������:
%   inFile - ��������� � ������������� ������:
%       inFile.Name - ��� �����;
%       inFile.HeadLenInBytes - ������ ��������� � ������;
%       inFile.NumOfChannels - ���������� ������� � ������;
%       inFile.ChanNum - 0..(NumOfChannels-1) ����� ������� ������;
%       inFile.DataType - ��� ������, ������������ ��� ��������:
%           'int16'/'double';
%       inFile.Fs0 - ������� ������������� ��� ������ �������;
%       inFile.dF - ����� �������, ������� ������� � ������ � �����
%           �������� ��� ���������� �������;
%       inFile.FsDown - ����������� ��������� ������� �������������
%           �������;
%       inFile.FsUp - ����������� ��������� ������� ������������� �������;
%   NumOfShiftedSamples - ���������� ��������, ������� ���� ���������� �
%       ����� ��� ���������� �������;
%   NumOfNeededSamples - ���������� ��������, ������� ���� ������� ��
%       �����.
%
% �������� ����������:
%   Signal - ��������� ������; Signal == [], ���� �� ������� ������� ����;
%       Signal == nan, ���� �� ������� ������ ��� ����������
%       NumOfNeededSamples ��������;
%   File - �������������� ����������; �� ��������� � inFile �����
%       ��������� �������������� ����:
%           File.Fs - ������� ������������� ����������� ������������������,
%               �.�. � ������ �����������������;
%           File.SamplesLen - ���������� �������� ������� � ������ ������ �
%               ������ �����������������.