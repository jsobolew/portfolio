classdef Copy_of_FMCW < handle
    %FMCW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Range               % Range vector 
        Velocity            % Velocity vector
        Parameters          % strct with radar parameters (vmax, lambda...)
        Settings            % struct with radar settings(fs, n...)
        RT                  % Range Time matrix
        noise               % struct with nose sttings   
        IR                  % impule response of matched filter
        ST                  % signal in slow time
        range_for_matched_filter
    end 
      
    methods
        function obj = Copy_of_FMCW(Range, Velocity, noise)
            %FMCW Construct an instance of this class
            obj.Range = Range;
            obj.Velocity = Velocity;
            obj.noise = noise;
            %FMCW settings
            obj.Settings.fs = 10e7;                 % fs of signal
            obj.Settings.fc = 5e9;                  % carrier wave frequency
            obj.Settings.B = 100e6;                 % deviation of frequency
            obj.Settings.PRF = 2000;                % Pulse repetition frequency
            obj.Settings.T = 1/obj.Settings.PRF;    % time of 1 chirp T = 1/PRF => PRI
            %FMCW Parameters
            obj.Parameters = obj.RadarParameters;
            
        obj.range_for_matched_filter = nonzeros(Range(4,:));
        end
        
        function Parameters = RadarParameters(obj)
            % vmax z prf i lambdy
            
            % wavelength OK
            Parameters.lambda = 3e8/obj.Settings.fc; %[m]
            
            % max velocity OK
            Parameters.Vmax = Parameters.lambda*obj.Settings.PRF/4; %[m/s]
            
            % velocity resolution depends on amount of chirps cannot
            % be calculated here
            %Parameters.Vres = Parameters.lambda/(2*obj.Settings.T*N); % [m/s]
            
            % length of signal OK
            Parameters.n = obj.Settings.T/(1/obj.Settings.fs); %[samples]

            % Range and frequency resolution OK both ways are good
            Parameters.FrequencyResolution = obj.Settings.fs/Parameters.n; %[Hz]
            Parameters.RangeResolution = ((Parameters.FrequencyResolution/2)/(obj.Settings.B))*(1/2000)*(3*1e8); %[m]
            Parameters.RangeResolution1 = 3e8/(2*obj.Settings.B);

            % max delay time = twice the time of 1 chirp
            maxDelayTime = (1/2000)*2; %[s]

            % range = c*maxDelayTime/2
            Parameters.Range = 3e8*(maxDelayTime/2); %[m]

            % steepness of frequency deviation
            Parameters.chrpSteepness = obj.Settings.B/obj.Settings.T; %[Hz/s]
        end
        
        function obj = generateRT(obj, numOfChirps)
            fc = obj.Settings.fc;
            fs = obj.Settings.fs;
            B = obj.Settings.B;
            T = obj.Settings.T;
            c = 3e8;
            
            % velocity resolution NOT OK
            obj.Parameters.Vres = obj.Parameters.lambda/(2*obj.Settings.T*numOfChirps); % [m/s]
            
            t = 0:1/fs:T-1/fs;
            n = length(t);

            % modulated signal
            tic
            %obj.RT = zeros(numOfChirps,((B/fs)*2*n)/1000);
            for i = 1:numOfChirps
                Mixed = zeros(1,n);
                for j = 1:size(obj.Range,1)
                    %V = obj.Velocity(i);
                    if (i < length(obj.Range))
                        R = obj.Range(j,i);
                        td = 2*R/c;
                        % GENERATING mixed and filterd signal (only cos(a-b))
                        %SingleObjectMixed = cos(2*pi*fc*td - (pi*B*(2*t*td + td^2)/T) + 2*fc*obj.Velocity(i)*t/c);
                        SingleObjectMixed = exp(1j.*(2*pi*fc*td - (pi*B*(2*t*td + td^2)/T) + 2*fc*obj.Velocity(j,i)*t/c));
                    else
                        %td = 0; 
                        % GENERATING mixed and filterd signal (only cos(a-b))
                        SingleObjectMixed = zeros(1,n);%cos(2*pi*fc*td - (pi*B*(2*t*td + td^2)/T) + 2*fc*0*t/c);
                    end

                    % WINDOW
                    %Mixed = Mixed.*hamming(length(Mixed))';
                    Mixed = Mixed + SingleObjectMixed;
                end
                if obj.noise.ON
                    Mixed = awgn(Mixed, obj.noise.SNR);
                end

                %Mixed = Mixed + SingleObjectMixed;
                FFT = fft((Mixed));
%                 if i > 1500 && i < 2500
%                     obj.ST(i,:) = Mixed;
%                 end
                obj.RT(i,:) = fliplr(FFT(end-((B/fs)*2*(length(Mixed)))/1000:end));%(1:((B/fs)*2*(length(Mixed)))/1000);%FFT;%fliplr(FFT(end-((B/fs)*2*(length(Mixed)))/1000:end));                   %(1:((B/fs)*2*(length(Mixed)))/1000);
            end
            toc
        end
        
    end
    
    methods(Static)
                
        function plotRT(RT, Settings, Parameters)
            n = Parameters.n;
            B = Settings.B;
            fs = Settings.fs;
            % ploting Range Time matrix
            max_frequency_on_plot = (length(RT)/n)*fs;
            max_distance_on_plot = (max_frequency_on_plot/2)/(B)*(1/2000)*(3*1e8);
                       

            %displaying matrix
            figure(1)
            imagesc(db(abs(RT))); colorbar;
            xlabel('Range [m]')
            ylabel('Time [ms]')
            title('Range time')
            
%             figure(5);
%             hold on
%             plot(db(imag(RT(:,68))));
%             plot(db(real(RT(:,68))));
%             plot(db(abs(RT(:,68))));
%             hold off
            %ir = real(RT(:,68));

            % labels
            set(gca, 'XTick', [0:0.05:1]*length(RT), 'XTickLabel', [0:0.05:1]*max_distance_on_plot) % 20 ticks 
            set(gca, 'YTick', [0:0.1:1]*size(RT, 1), 'YTickLabel', [0:0.1:1]*1/2000*1000*size(RT, 1)) % 10 ticks
            
        end
        function RD = plotRD(RT, Settings, Parameters, VelocityOrNotDopplerFrequency)
            % ploting Range Doppler matrix
            RD = zeros(size(RT, 1),size(RT, 2));
            for i = 1:size(RT, 2)
                RD(:,i) = RD(:,i).*hanning(size(RT, 1));
                RD(:,i) = fftshift(fft(RT(:,i))); 
            end
            
            % filtering stationary objects
            %RD(round(size(RD,1)/2),:) = 0;
            
            %displaying matrix
            figure(2)
            imagesc(db(abs(RD))); colorbar;
            title('Doppler time')

            %labels
            set(gca, 'XTick', [0:0.05:1]*length(RT), 'XTickLabel', [0:0.05:1]*150) % 20 ticks 
            xlabel('Range [m]')
            
            if VelocityOrNotDopplerFrequency
                set(gca, 'YTick', [0:0.1:1]*(size(RT, 1)+1), 'YTickLabel', [-0.5:0.1:0.5]*(-Parameters.Vmax*2)) % 10 ticks
                ylabel('Radial Velocity [m/s]')
            else
                set(gca, 'YTick', [0:0.1:1]*(size(RT, 1)+1), 'YTickLabel', [-0.5:0.1:0.5]*(-Settings.PRF*2)) % 10 ticks
                ylabel('Doppler [Hz]')
            end        
        end
        
        function plot_new_RT(RT,range_for_matched_filter,lambda)
            for i = 1:size(RT,2)          
             phase = 4*pi/lambda*(range_for_matched_filter+i*1.5);
             h = conj(fliplr(exp(1j.*phase)));
             RT(:,i) = filter(h,1,RT(:,i));
            end
            
            %displaying matrix
            figure(21)
            imagesc(db(abs(RT))); colorbar;
            xlabel('Range [m]')
            ylabel('Time [ms]')
            title('Range time')
        end
    end
end

