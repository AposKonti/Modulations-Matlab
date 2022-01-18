M = [2, 4, 8, 16];
source_bits = 3*2^8;
SNR = [0, 5, 10, 15, 20, 25, 30, 35, 40];
SER = [];
BER = [];
counter = 1;
for i=1:2
    for j=1:length(M)
        for snr=0:5:40
            [SER(counter), BER(counter)] = my_mpam(source_bits, M(j), snr, i-1);
            counter = counter + 1;
        end
    end
end
 
figure
title(sprintf('BER by SNR'));
hold on
x = SNR;
for i =1:9:length(BER)
    temp = BER(i:i+9-1);
    y = log2(temp);
    plot(x,y);
end
set(gca, 'YScale', 'log')
hold off
legend({'No Grey M=2','No Grey M=4','No Grey M=6','No Grey M=8','Grey M=2','Grey M=4','Grey M=6','Grey M=8'},'FontSize',12,'TextColor','blue', 'Location','northeast');
legend('boxoff')
grid on
 
figure
title(sprintf('SER by SNR'));
hold on
x = SNR;
for i =1:9:length(SER)
    temp = SER(i:i+9-1);
    y = temp;
    plot(x,y);
end
hold off
legend({'No Grey M=2','No Grey M=4','No Grey M=6','No Grey M=8','Grey M=2','Grey M=4','Grey M=6','Grey M=8'},'FontSize',12,'TextColor','blue', 'Location','northeast');
legend('boxoff')
grid on
