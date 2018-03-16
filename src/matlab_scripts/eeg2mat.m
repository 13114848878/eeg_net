% ����������� ��������� ������ � ��� ������� � ������� � ������ ���� .mat
clear all; close all; clc % ������� ������, ������� �������
EXP_NUM = 21;
EXP_SHIFT = 167;
% �������� �����, ������� ����� �� ���������
exlabels = csvread('exlabels.csv');
[h, w] = size(exlabels);
[flab{1:EXP_NUM}] = deal([]);
for y = 1:h
    enum = exlabels(y, 1);
    flab{enum}(end + 1) = exlabels(y, 2);
end
% eeg_num = 1;
 for eeg_num = 1:21 % ���� �� ���� ������� ������
    infile_labels = sprintf('labels\\D%07d.TXT', eeg_num + EXP_SHIFT);
    infile_eeg = sprintf('eeg\\D%07d.TXT', eeg_num + EXP_SHIFT); 
    
    % ��������� ���� � �������
    data = dlmread(infile_labels,'', 1, 0);
    % ��������� ���� � �������
    if ~isempty(flab{eeg_num})
        data = removerows(data, 'ind', flab{eeg_num});
    end
    
    % ������� �������������� �����
    [h, w] = size(data);
    indices = [];
    for y = 1:h
        if data(y, 2) <= 50
            indices(end + 1) = y;
        end
    end
    data = removerows(data, 'ind', indices);
    
    
    
    time = data(:,1);
    label = data(:,2);
    
    % ����������� ������ �����: 49 � 51 = 1 - �����, 50 � 52 = 2 - �������
    label(label==49) = 1; label(label==51) = 1;
    label(label==50) = 2; label(label==52) = 2;
    label = int64(label);

    fs = 250; % ������� ������������� 250 ��
    time = time.*fs; % ��������� ��������� ����� � ������� �������
    time = int64(time); % ��������� � �������������� �������

    s = struct; % ������� ��������� ��� ������ � .mat ����
    s.fs = fs;

    data = dlmread(infile_eeg,'', 0, 0);
    [~, C] = size(data);
    [T, ~] = size(label);
    shift = int64(1.1 * 250); % ����� ������ ��������� = 1100 �� * 250 ��
    shift1 = int64(0.15 * 250);
    shift2 = int64(0.42 * 250);
    eeg = zeros(shift, C, T);
    for trial = 1:T % ���� �� ���� ����������
        for channel = 1:C % ���� �� ���� �������
            ch_data = data(:, channel);
            index = 1;
            for y = time(trial, 1)+shift1:time(trial, 1)+shift2-1 % ���� �� ���� �������� ������ ���������
                eeg(index, channel, trial) = ch_data(y, 1);
                index = index + 1;
            end
        end
    end
    s.eeg = eeg; % ��������� � ��������� ��� ������
    s.mrk = label; % ��������� � ��������� ��������������� �����
    output_name = sprintf('eegmat_selected\\D%07d.mat', eeg_num + EXP_SHIFT);
    save(output_name, 's'); % ��������� .mat ����
 end