classdef SortLMMotionMatlab < mlan.AbstractListmode % & mlan.ISortLMMotionMatlab
	%% SORTLMMOTIONMATLAB forks IDL codes SortLM_motion from Richard Laforest

	%  $Revision$
 	%  was created 16-Jun-2017 00:49:14 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 Richard Laforest and John Joowon Lee.
 	
    
    properties (Constant)  
        BUFFER_LENGTH = 65536
        DEBUG = true      
        TVEC_DIM = 2000
    end

	properties
        Nbin % This is the maximum number of bins that can be prcossed at the same time.
              % It is determined by the total memory available
        saveSinograms 
    end
    
    properties (Dependent)
        dir0
        listmode
        mrBinning
        petBinning
        sinogram
        studyName
    end
    
	methods 
	
        %% GET/SET
        
        function g = get.dir0(this)
            g = this.dir0_;
        end
        function g = get.listmode(this)
            g = this.listmode_;
        end
        function g = get.mrBinning(this)
            g = this.mrBinning_;
        end
        function g = get.petBinning(this)
            g = this.petBinning_;
        end
        function g = get.sinogram(this)
            g = this.sinogram_;
        end
        function g = get.studyName(this)
            g = this.studyName_;
        end
        
        function this = set.dir0(this, s)
            assert(isdir(s));
            this.dir0_ = s;
        end
        function this = set.studyName(this, s)
            assert(ischar(s));
            this.studyName_ = s;
        end
        
        %%
            
        function plot(this)
            
            tstep = this.mrBinning_.tstep;
            Nt = 2000;
            meant = mean(this.timepos(1:Nt));
            fft_timepos = real(fft(this.timepos(1:Nt) - meant));
            dt = tstep/1000; % $\mu$sec
            Nomega = length(fft_timepos);
            omega = 0:(Nomega - 1)/2;
            if (mod(Nomega, 2) == 0)
                freq = [0.0 omega  Nomega/2 (omega -  Nomega/2)]/(Nomega*dt);
            else
                freq = [0.0 omega           (omega - (Nomega/2 + 1))]/(Nomega*dt);
            end
            
            figure;
            plot(this.timepos(1:300), this.amin, this.timepos(1:300), this.amax);
            fid44 = this.fopen( ...
                fullfile(this.dir0, sprintf('%s_PETtime_%ims_%ims.dat', this.studyName, tstep, this.tstart0)), 'w');
            for ip = 1:Nt
                fprintf(fid44, '%g\t%g\t%g\t%g\n', ip*tstep+this.tstart0, this.timepos(ip), freq(ip), fft_timepos(ip));
            end
            
            figure;
            title('plot');
            xlabel('freq');
            ylabel('yf := FFT\{this.timepos - <this.timepos>\}');
            xl = 0;
            xh = 300;
            %this.dprintf('plot', freq(xl:xh));
            %this.dprintf('plot', yf(xl:xh));
            plot(freq(xl:xh), fft_timepos(xl:xh));
            
            figure;
            title('plot');
            h1 = plot( this.tvecMR(0:200));
            holdon;
            h2 = plot( this.tvecPT);
            ylabel(h1, 'tvecMR(0:200)');
            ylabel(h2, 'tvecPT');            
            this.dprintf('plot', 'minind = %g, maxind = %g', this.minind, this.maxind);
        end        
        function this = save(this)
            if (this.saveSinograms)
                this.sinogram.save;
            end
        end
        
 		function this = SortLMMotionMatlab(varargin)
 			%% SORTLMMOTIONMATLAB
 			%  Usage:  this = SortLMMotionMatlab()
            
            ip = inputParser;
            addParameter(ip, 'dir0', '/data/anlab/Hongyu/Phantom_24Jan2017/Gated/jjlee', @isdir);
            addParameter(ip, 'fileMRbin', 'BinningResult_5bins.txt', @ischar);
            addParameter(ip, 'filePETbin', 'PETMR_bintable_JJL.dat', @ischar);
            addParameter(ip, 'fileprefixPTD', 'Motion-LM-00', @ischar);
            addParameter(ip, 'Nbin', 5, @isnumeric);
            addParameter(ip, 'saveSinograms', true, @islogical);
            addParameter(ip, 'studyName', 'Phantom5Bins_JJL_', @ischar);
            addParameter(ip, 'tstep', 170, @(x) isnumeric && x >= 85);
            parse(ip, varargin{:});
 			this.dir0_ = ip.Results.dir0;
            this.Nbin = ip.Results.Nbin;
            this.saveSinograms = ip.Results.saveSinograms;
            this.studyName_ = ip.Results.studyName;  
            
            cd(this.dir0);
            import mlan.*;
            this.mrBinning_  = MRBinningParser.load(ip.Results.fileMRbin, 'tstep', ip.Results.tstep);
            this.petBinning_ = PETBinningParser.new(ip.Results.filePETbin);
            this.listmode_   = Listmode('filepath', this.dir0_, 'fileprefix', ip.Results.fileprefixPTD); 
            this.sinogram_   = Sinogram('listmode', this.listmode_, 'Nbin', this.Nbin, 'studyName', this.studyName_);
            
            this.minind = Inf;
            this.maxind = -Inf;
            
        end
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        amax
        amin 
        maxind
        minind
        timepos
        tstart0 = 0
        tvecMR
        tvecPT    
    end
    
    %% PRIVATE
    
    properties (Access = private)
        dir0_
        listmode_
        mrBinning_
        petBinning_
        sinogram_
        studyName_
    end
    
    %% HIDDEN
    
    methods (Hidden)      
          
        function SortLM_motion(this)
            %% SORTLM_MOTION is Richard's main.   
            %  R. Laforest
            %  MIR
            %  Version: 01-FEB-2017
            %  Adapted for porting to Matlab by J. Lee.           
            
            %
            % Setup info from listmode header file
            %
            this.dprintf('SortLM_motion', 'Scan Time and Day  %s on %s', this.listmode.studyTime, this.listmode.studyDate);            
            this.dprintf('SortLM_motion', 'Sinogram data = %g %g %g %g %g %g', ...
                this.listmode.xdim, this.listmode.ydim, this.listmode.zdim,  ...
                this.listmode.nsegments, this.listmode.number_of_rings, this.listmode.max_ring_difference);
            this.dprintf('SortLM_motion', 'Segtable = %s', num2str(this.listmode.segtable));            
            this.dprintf('SortLM_motion', 'Allocating memory, sinoNumel(bytes) = %i', numel(this.sinogram));
            
            %
            % Setup this.mrBinning_
            %
            %this.mrBinning_ = this.mrBinning_.setIbinTo100;
            this.tvecMR = zeros(this.TVEC_DIM, 1, 'uint16');
            this.tvecPT = zeros(this.TVEC_DIM, 1, 'uint16');
            
            %
            % Data driven PET info
            %
            this.timepos = zeros(this.mrBinning_.nmarkers, 1, 'single');
            timemarker = 1;
            
            % ------------------------------------------------------------------------------
            %
            %                     Start reading listmode file HERE
            %
            % ------------------------------------------------------------------------------
            
            nlook = this.BUFFER_LENGTH;
            nbblock = fix(this.listmode.wordCounts/this.BUFFER_LENGTH); % num buffer blocks ~ 1375
            remainder = mod(this.listmode.wordCounts, nlook); % remainder of buffer blocks in longwords ~40781
            this.dprintf('SortLM_motion', 'num. buffer blocks = %g, remainder = %i', nbblock, remainder);
            tlread = 0; % total longwords read
            
            fid33 = fopen(this.listmode.fqfilename);
            for ibf = 1:nbblock+1
                
                if (ibf == nbblock+1)
                    if (remainder == 0)
                        break
                    end
                    nlook = this.listmode.wordCounts - tlread; % ~90087245 - tlread
                end
                arrayL = fread(fid33, nlook, 'uint32=>uint32', 0, 'ieee-le');              
                tlread = tlread + length(arrayL);
                %this.dprint('SortLM_motion', 'Total number of longwords read : %i %g %i %g', ibf, tlread, this.listmode.wordCounts, time)
                
                %% loop within buffer block
                for ifl = 1:nlook
                    
                    tagPacketBitL  = bitshift(arrayL(ifl), -31, 'uint32'); 
                    tagTimeMarkerL = bitshift(arrayL(ifl), -30, 'uint32'); 
                    tagPhysioL     = bitshift(arrayL(ifl), -28, 'uint32'); 
                    
                    %% prompts or randoms
                    if (tagPacketBitL == 0 && this.mrBinning_.hasTimeMarker)
                        
                        % lots of small local variables ...
                        prtL  = bitshift(arrayL(ifl), -30, 'uint32');
                        addrL = bitand(arrayL(ifl), this.hex2ulong('1FFFFFFF'), 'uint32');
                        izpL  = addrL/(this.listmode.xdim*this.listmode.ydim);
                        ivwL  = (addrL - izpL*this.listmode.xdim*this.listmode.ydim)/ this.listmode.xdim;
                        iprL  = (addrL - izpL*this.listmode.xdim*this.listmode.ydim - ivwL*this.listmode.xdim);
                        indL  = iprL;  %(iprL-this.listmode.xdim/2)*2+this.listmode.xdim/2
                        
                        this.minind = min(indL, this.minind);
                        this.maxind = max(indL, this.maxind);
                        
                        if (addrL <= numel(this.sinogram))
                            % this.Nbin limited by available physical memory ~ 5
                            if (prtL == 1 && this.mrBinning_.ibin < this.Nbin)
                                this.sinogram_ = this.sinogram_.promptsPP(this.mrBinning_.ibin, addrL);
                                
                                %% CUT in vertical position
                                if (abs(ivwL-120) <= 10)
                                    this.petBinning_.avgpos = this.petBinning_.avgpos + single(indL);
                                    this.petBinning_.nbpos  = this.petBinning_.nbpos + 1;
                                end
                            end
                            if (prtL == 0 && this.mrBinning_.ibin < this.Nbin)                                
                                this.sinogram_ = this.sinogram_.randomsPP(this.mrBinning_.ibin, addrL);
                            end
                        else
                            warning('mlan:arrayAddressErr', ...
                                    'SortLM_motion: Bad Sino Address ...%12i%12i  %32.32bx', ...
                                    (ibf-1)*nlook+(ifl-1), addrL, arrayL(ifl));
                        end
                        
                    end %% end of prommpt or randoms
                    
                    %% Time tags and dead time tracking -- TAG1
                    if (tagTimeMarkerL == 2)
                        
                        tagGantryL = bitshift(arrayL(ifl), -29, 'uint32');
                        
                        %% Time tags
                        if (tagGantryL == 4)
                            
                            this.petBinning_.time = bitand(arrayL(ifl), this.hex2ulong('1FFFFFFF'), 'uint32'); %% in msec
                            
                            %this.dprintf('SortLM_motion', 'Running time = %g %g %g %i %g', tag, this.petBinning_.time, this.petBinning_.frame_time, this.mrBinning_.hasTimeMarker, frame_duration)
                            if (this.mrBinning_.hasTimeMarker && this.mrBinning_.ibin < this.Nbin)
                                this.sinogram_ = this.sinogram_.tickPerBinPP(this.mrBinning_.ibin);
                            end
                            
                            %% Skip to the first MR time marker
                            if (this.petBinning_.frame_time >= this.mrBinning_.tstart)
                                this.mrBinning_ = this.mrBinning_.resetIbin;
                            end
                            
                            %% Normal processing...
                            if (this.petBinning_.frame_time >= this.mrBinning_.tlast && this.petBinning_.frame_time < this.mrBinning_.TFinal)
                                
                                if (this.mrBinning_.hasNext)
                                    this.mrBinning_ = this.mrBinning_.next;
                                else
                                    this.save;
                                    this.plot;
                                    fclose(fid33);
                                    return
                                end
                                if (~isnan(this.mrBinning_.ibin))
                                    if (this.mrBinning_.ibin > this.Nbin)
                                        error('mlan:counterErr', 'bin number is too large!\n%g\n', this.mrBinning_.ibin);
                                    end
                                    this.mrBinning_ = this.mrBinning_.setIbin0;
                                    %dprintf('SortLM_motion', 'Current Bin time = %g %g %i %i %g %i %i', ...
                                    %this.mrBinning_.tstart, this.mrBinning_.tlast, this.mrBinning_.ibin, this.mrBinning_.ibin, this.petBinning_.frame_time, this.mrBinning_.hasTimeMarker, this.mrBinning_.ibin0);
                                    %dprintf('SortLM_motion', '%10i %10i %10i %10i %10i %10i', ...
                                    %this.sinogram_.tickPerBin(0:this.Nbin-1), this.total(this.sinogram_.tickPerBin));
                                    this.timepos(timemarker) = single(this.petBinning_.avgpos)/this.petBinning_.nbpos;
                                    timemarker = timemarker + 1;
                                    
                                    %% PET only time increment
                                    %ibin = 1    % no PET sorting
                                    
                                    %% PET data driven bins
                                    %% use this.petBinning_.avgpos to provide the bin number
                                    this.amin = 153.5;    % 153.5
                                    this.amax = 157;
                                    astep = (this.amax-this.amin)/5;
                                    abin  = (single(this.petBinning_.avgpos)/this.petBinning_.nbpos - this.amin);
                                    ibinP = fix(abin/astep);
                                    if (ibinP <= 0); ibinP = 0; end
                                    if (ibinP >= 4); ibinP = 4; end
                                    this.mrBinning_ = this.mrBinning_.setIbin0;
                                    this.petBinning_.avgpos = 0;
                                    this.petBinning_.nbpos = 0;
                                end
                                % ibin = ibinP
                                this.mrBinning_ = this.mrBinning_.setIbin0;
                                % ibin = 1 % no PET sorting % should be removed
                                this.petBinning_.fprintf('%g %g %g %i %i\n', ...
                                    this.mrBinning_.tstart, this.petBinning_.time, this.petBinning_.frame_time, this.mrBinning_.ibin, ibinP);
                                this.tvecMR(timemarker-1) = this.mrBinning_.ibin;
                                this.tvecPT(timemarker-1) = ibinP;
                            end
                            
                            %% stop reading PET after the last MR time marker
                            if (this.petBinning_.frame_time >= this.mrBinning_.TFinal)
                                this.mrBinning_ = this.mrBinning_.setIbinTo100;                                
                                this.mrBinning_.hasTimeMarker = false;
                                this.save;
                                this.plot
                                fclose(fid33);
                                return
                            end
                            
                        end %% Time tags
                        
                        %% Singles data
                        if (tagGantryL == 5)
                            block   = bitand(bitshift(arrayL(ifl), -19, 'uint32'), this.hex2ulong('3FF'), 'uint32');
                            singles = bitand(arrayL(ifl), this.hex2ulong('7FFFF'), 'uint32');
                            %this.dprintf('SortLM_motion', 'Block and singles #s.... %i %i', block, singles
                            if (block < this.listmode.nbuckets)
                                this.sinogram_ = this.sinogram_.assignSinglesRates(block+1, singles);
                            end
                        end
                        
                    end % of ttag = 2
                    
                    %% Physio triggers -- TAG3
                    if (tagPhysioL == 14)
                        this.dprintf('SortLM_motion', 'Physio trigger format# %i', ...
                            bitand(bitshift(arrayL(ifl), -24, 'uint32'), this.hex2ulong('0F'), 'uint32'));
                        this.dprintf('SortLM_motion', '%8i     %32bx\n', this.petBinning_.time, arrayL(ifl));
                    end                    
                    if (tagPhysioL == 15)
                        this.dprintf('SortLM_motion', 'Control acquisition parameters# %i %8i\n', ...
                            bitand(bitshift(arrayL(ifl), -24, 'uint32'), this.hex2ulong('0F'), 'uint32'), this.petBinning_.time);
                        %this.dprintf('SortLM_motion', '%8i .  %32bx', this.petBinning_.time, arrayL(ifl));
                    end
                    
                end %% Loop within buffer block
                
            end %% Loop buffer blocks         
            
            this = this.save;
            this.plot;  
            fclose(fid33);
        end        
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

