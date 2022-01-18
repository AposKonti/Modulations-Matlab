function [SER, BER] = my_mpam(num_of_bits, M, SNR, grey)
    %---Creating Source
    source = randsrc(1,num_of_bits,[0 1]);

    %---Mapper
    symbol_len = log2(M);
    Mapper = "";
    for index = 1:M
        if grey == 0
            for i=1:M
                Mapper(1,i) = num2str(dec2bin(i-1,log2(M)));
            end
        elseif grey ==1
            g = dec2bin(index-1,symbol_len);
            for j = 2:length(g)
                g(j) = num2str(xor(str2num(g(j-1)),str2num(g(j)))); 
            end
            Mapper(1,index) = g;
        end
    end
    for index = 1:length(Mapper)
        Mapper(2,index) = 2*index-1-M;
    end

    %---Mapping Source
    if symbol_len == 1
        x=source;
        x(x==0)=Mapper(2,1);
    else
        x = [];
        index = 1;
        for i = 1:symbol_len:length(source)
            part = "";
            for k = 1:symbol_len
                part = strcat(part,num2str(source(i+k-1)));
            end
            for j = 1:length(Mapper)
                if part == Mapper(1,j)
                    x(index) = Mapper(2,j);
                end
            end
            index = index + 1;
        end
    end
    clear i j g k part index num_of_bits

    %---Creating signal
    sample_time = 0.0000001;
    sym_time = 0.000004;
    t=0:sample_time:sym_time*length(x);
    A = ceil(sqrt(3/(sym_time*((M.^2)-1))));
    fc = 2500000;
    g = sqrt(2/sym_time);
    step = sym_time/sample_time;
    counter = 1;
    signal = [];

    %---Modulation
    for i=0:step:length(t)-2
         dt = t(i+1:i+step);
         s=x(counter)*A*g*cos(2*pi*fc*dt);
         counter=counter+1;
         signal=[signal s];
    end
    centers = [];
    for i=1:step:length(signal)
        centers = [centers, signal(i)];
    end
    centers = sort(unique(centers));
    %---Noise
    %---Creating 
    dispersion = (10.^(-SNR/10)) / 2*log2(M);
    noise = randn([1 length(signal)])*sqrt(dispersion);                            
    signal_n = awgn(signal,SNR,'measured');

    clear  dt s counter A signal sample_time dispersion noise

    final=[];
    for i=1:step:length(signal_n)
        min_value = inf;
        pos = -1;
        for j=1:length(centers)
            diff = abs(centers(j)-signal_n(i));
            if (diff < min_value)
                min_value = diff;
                pos = j;
            end
        end           
        final = [final, str2double(Mapper(2,pos))];
    end

    % De-Mapping 
    output = [];
    for i = 1:length(final)
        for j = 1:length(Mapper)
            if final(i) == str2double(Mapper(2,j)) %Mapper(1,j) -> Grey "0001" -> '0001'
                char = convertStringsToChars(Mapper(1,j));
                for k = 1:length(char)
                    output = [output, str2double(char(k))];
                end
            end
        end
    end
    SER = nnz(x - final)/length(final);
    BER = nnz(source - output)/length(source);

    clear dt fc g  index j M temp t sym_time symbol k char diff i min_value pos step symbol_len
end