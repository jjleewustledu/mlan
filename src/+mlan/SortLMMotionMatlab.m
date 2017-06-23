classdef SortLMMotionMatlab < mlan.AbstractIO % & mlan.ISortLMMotionMatlab
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
        nbins % This is the maximum number of bins that can be prcossed at the same time.
              % It is determined by the total memory available
        saveSino
        
        nbctrl % control acq
        nbphy  % physio tags
        nbprt  % prompts
        nbrnd  % randoms
        nbttag % time tags
    end
    
    properties (Dependent)
        dir0
        listmode
        mrBinning
        petBinning
        sinoNumel % this.listmode.xdim*this.listmode.ydim*this.listmode.zdim
        studyName
        tstep % msec time step; min = 85?
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
        function g = get.sinoNumel(this)
            g = this.listmode.xdim*this.listmode.ydim*this.listmode.zdim;
        end
        function g = get.studyName(this)
            g = this.studyName_;
        end
        function g = get.tstep(this)
            g = this.mrBinning_.tstep;
        end
        
        function this = set.dir0(this, s)
            assert(isdir(s));
            this.dir0_ = s;
        end
        function this = set.studyName(this, s)
            assert(ischar(s));
            this.studyName_ = s;
        end
        function this = set.tstep(this, s)
            assert(isnumeric(s) && s >= 85);
            this.mrBinning_.tstep = s;
        end
        
        %%
            
        function plot(this)
            
            this.dprintf('plot', 'Clearing memory, closing all files and exiting.\n');
            Npts = 2000;
            mean_ = mean(this.timepos(1:Npts));
            yf = real(fft(this.timepos(1:Npts)-mean_));
            dt = this.tstep/1000;
            Nyf = length(yf);
            X = 0:(Nyf - 1)/2;
            if (mod(Nyf,2) == 0)
                freq = [0.0, X,   Nyf/2, -Nyf/2 + X]/(Nyf*dt);
            else
                freq = [0.0, X, -(Nyf/2 + 1) + X]/(Nyf*dt);
            end
            
            %figure;
            %plot(this.timepos(1:300), this.amin, this.timepos(1:300), this.amax);
            %filespec = dialog_pickfile(filter='*.dat', path=this.dir0)
            %if (strcmp(filespec, '')); stop; end
            fid44 = fopen(fullfile(this.dir0, sprintf('%s_PETtime_%ims_%ims.dat', this.studyName, this.tstep, this.tstart0)), 'w');
            for ip = 1:Npts
                fprintf( fid44, ip*this.tstep+this.tstart0, this.timepos(ip), freq(ip), yf(ip));
            end
            
            figure;
            title('plot');
            xlabel('freq');
            ylabel('yf := fft(this.timepos-mean_)');
            xl = 0;
            xh = 300;
            %this.dprintf('plot', yf(xl:xh));
            %this.dprintf('plot', freq(xl:xh));
            plot( freq(xl:xh), yf(xl:xh));
            
            figure;
            title('plot');
            h1 = plot( this.tvecMR(0:200));
            holdon;
            h2 = plot( this.tvecPT);
            ylabel(h1, 'tvecMR(0:200)');
            ylabel(h2, 'tvecPT');      
            
            this.dprintf('plot', 'minindL = %g, maxindL = %g', this.minindL, this.maxindL);
        end
        function save_hdr(this, hdrout, fileout, injection_start_time, tprompts, trandoms)
            %% SAVE_HDR saves Siemens sinogram header
            %  @params hdrout is char.
            %  @params fileout is char.
            %  @params injection_start_time has format 'HH:MM:SS'.
            
            ip = inputParser;
            addRequired(ip, 'hdrout', @ischar);
            addRequired(ip, 'fileout', @ischar);
            addRequired(ip, 'injection_start_time', @(x) ~isnat(datetime(x)));
            addRequired(ip, 'tprompts', @isnumeric);
            addRequired(ip, 'trandoms', @isnumeric);
            parse(ip, hdrout, fileout, injection_start_time);
            
            this.dprintf('save_hdr', sprintf('Writing sinogram header :%s', hdrout)); 
            if (2 == exist(hdrout, 'file'))
                movefile(hdrout, this.appendFileprefix(hdrout, ['_backup' datestr(now,30)]));
            end
            
            fid34 = fopen(hdrout);
            fprintf( fid34, '!INTERFILE:=\n');
            fprintf( fid34, '%%comment:=Created from listmode data\n');
            fprintf( fid34, '!originating system:=2008\n');
            fprintf( fid34, '%%SMS-MI header name space:=sinogram subheader\n');
            fprintf( fid34, '%%SMS-MI version number:=3.4\n');
            fprintf( fid34, '\n');
            fprintf( fid34, '!GENERAL DATA:=\n');
            fprintf( fid34, '%%listmode header file:=%s\n', sprintf(this.dir0, 'Motion-LM-00.hdr'));
            fprintf( fid34, '%%listmode data file:=%s\n', sprintf(this.dir0, 'Motion-LM-00.l'));
            fprintf( fid34, '!name of data file:=%s\n', this.basename(fileout));
            fprintf( fid34, '  \n');
            fprintf( fid34, '!GENERAL IMAGE DATA:=\n');
            fprintf( fid34, '%%study date (yyyy:mm:dd):=%s\n', this.listmode.studyDate);
            fprintf( fid34, '%%study time (hh:mm:ss GMT+00:00):=%s\n', this.listmode.studyTime);
            fprintf( fid34, 'isotope name:=F-18\n');
            fprintf( fid34, 'isotope gamma halflife (sec):=6586.2\n');
            fprintf( fid34, 'isotope branching factor:=1\n');
            fprintf( fid34, 'radiopharmaceutical:=FDG\n');
            fprintf( fid34, '%%tracer injection date (yyyy:mm:dd):=%s\n', this.listmode.studyDate);
            fprintf( fid34, '%%tracer injection time (hh:mm:ss GMT+00:00):=%s\n',injection_start_time);
            fprintf( fid34, 'tracer activity at time of injection (Bq):=3.7e+006\n');
            fprintf( fid34, 'relative time of tracer injection (sec):=0\n');
            fprintf( fid34, 'injected volume (ml):=0.0\n');
            fprintf( fid34, 'image data byte order:=LITTLEENDIAN\n');
            fprintf( fid34, '%%patient orientation:=HFS\n');
            fprintf( fid34, '!PET data type:=emission\n');
            fprintf( fid34, 'data format:=sinogram\n');
            fprintf( fid34, '%%compression:=off\n');
            fprintf( fid34, '%%compressor version:=1.1\n');
            fprintf( fid34, 'number format:=signed integer\n');
            fprintf( fid34, '!number of bytes per pixel:=2\n');
            fprintf( fid34, 'number of dimensions:=3\n');
            fprintf( fid34, 'matrix axis label[1]:=sinogram projections\n');
            fprintf( fid34, 'matrix axis label[2]:=sinogram views\n');
            fprintf( fid34, 'matrix axis label[3]:=number of sinograms\n');
            fprintf( fid34, 'matrix size[1]:=%i\n', this.listmode.xdim);
            fprintf( fid34, 'matrix size[2]:=%i\n', this.listmode.ydim);
            fprintf( fid34, 'matrix size[3]:=%i\n', this.listmode.zdim);
            fprintf( fid34, 'scale factor (mm/pixel) [1]:=%i\n', this.xsize*10.);
            fprintf( fid34, 'scale factor (degree/pixel) [2]:=%i\n', 180./this.listmode.ydim);
            fprintf( fid34, 'scale factor (mm/pixel) [3]:=%i\n',this.zsize*10.);
            fprintf( fid34, 'horizontal bed translation:=stepped\n');
            fprintf( fid34, 'start horizontal bed position (mm):=-2\n');
            fprintf( fid34, 'end horizontal bed position (mm):=-2\n');
            fprintf( fid34, 'start vertical bed position (mm):=0.0\n');
            fprintf( fid34, '%%axial compression:=1\n');
            fprintf( fid34, '%%maximum ring difference:=%i\n', this.listmode.max_ring_difference);
            fprintf( fid34, 'number of rings:=%i\n', this.listmode.number_of_rings);
            fprintf( fid34, '%%number of TOF time bins:=1\n');
            fprintf( fid34, '%%TOF mashing factor:=1\n');
            fprintf( fid34, '%%sinogram type:=step and shoot\n');
            fprintf( fid34, '%%number of segments:=%i\n', this.listmode.nsegments);
            fprintf( fid34, '%%segment table:=%s\n', this.listmode.segtable);
            fprintf( fid34, '%%total number of sinograms:=%s\n',this.listmode.zdim);
            fprintf( fid34, 'number of energy windows:=1\n');
            fprintf( fid34, '%%energy window lower level (keV) [1]:=430\n');
            fprintf( fid34, '%%energy window upper level (keV) [1]:=610\n');
            fprintf( fid34, 'gantry tilt angle (degrees):=0.0\n');
            fprintf( fid34, '%%coincidence window width (ns):=5.85938\n');
            fprintf( fid34, 'number of scan data types:=2\n');
            fprintf( fid34, 'scan data type description[1]:=prompts\n');
            fprintf( fid34, 'scan data type description[2]:=randoms\n');
            fprintf( fid34, 'data offset in bytes[1]:=0\n');
            fprintf( fid34, 'data offset in bytes[2]:=%i\n', this.listmode.xdim*this.listmode.ydim*this.listmode.zdim*2);
            fprintf( fid34, '\n');
            fprintf( fid34, '!IMAGE DATA DESCRIPTION:=\n');
            fprintf( fid34, '!total number of data sets:=1\n');
            fprintf( fid34, 'total prompts:=%15i\n', this.long(tprompts));
            fprintf( fid34, '%%total randoms:=%15i\n', this.long(trandoms));
            fprintf( fid34, '%%total net trues:=%i\n', this.long(tprompts-trandoms));            
            if (fix(single(this.fduration)/1000) > 2) % this one needs to be atleast 2 sec
                fprintf( fid34, '!image duration (sec):=%s\n', strtrim(string(fix(single(this.fduration)/1000))));
            else
                fprintf( fid34, '!image duration (sec):=2\n');
            end
            fprintf( fid34, '!image relative start time (sec):=%f8.1\n', single(this.fstart)/1000);
            fprintf( fid34, '%%image duration from timing tags (msec):=%i\n', this.fduration);
            fprintf( fid34, '%%GIM loss fraction:=1\n');
            fprintf( fid34, '%%PDR loss fraction:=1\n');
            fprintf( fid34, '\n');
            fprintf( fid34, '%%DETECTOR BLOCK SINGLES:=\n');
            fprintf( fid34, '%%number of buckets:=%15i\n', fix(this.listmode.nbuckets));
            fprintf( fid34, '%%total uncorrected singles rate:=%s\n', strtrim(string(this.long(8*this.total(this.singles_rates)))));
            for ibb = 1:this.listmode.nbuckets
                fprintf( fid34, '%%bucket singles rate[%s]:=%s\n', strtrim(num2str(ibb)), strtrim(num2str(8*this.singles_rates(ibb))));
            end            
            fprintf( fid34, '\n');
            fclose(fid34);            
        end
        function save_mhdr(this, fbase, nframes)
            %% SAVE_MHDR saves a Siemens main header; if an identically named file exists, the existing file 
            %  is backed up with suffix ['_backup' datestr(now,30)].
            %  @params fbase is the filename base.
            %  @params nframes is numeric.
            
            ip = inputParser;
            addRequired(ip, 'fbase', @ischar);
            addRequired(ip, 'nframes', @isnumeric);
            parse(ip, fbase, nframes);
            
            filemhdr = fullfile(this.dir0, [fbase 'sino.mhdr']);
            if (2 == exist(filemhdr, 'file'))
                movefile(filemhdr, this.appendFileprefix(filemhdr, ['_backup' datestr(now,30)]));
            end
            
            fid22 = fopen(filemhdr, 'w');            
            fprintf( fid22, '!INTERFILE:=\n');
            fprintf( fid22, '%%comment:=SMS-MI sinogram common attributes\n');
            fprintf( fid22, '!originating system:= 2008\n');
            fprintf( fid22, '%%SMS-MI header name space:=sinogram main header\n');
            fprintf( fid22, '%%SMS-MI version number:=3.1\n');
            fprintf( fid22, '\n');
            fprintf( fid22, '!GENERAL DATA:=\n');
            fprintf( fid22, 'data description:=sinogram\n');
            fprintf( fid22, 'exam type:=wholebody\n');
            fprintf( fid22, '%%study date (yyyy:mm:dd):= %s\n', this.listmode.studyDate);
            fprintf( fid22, '%%study time (hh:mm:ss GMT+00:00):= %s\n',this.listmode.studyTime);
            fprintf( fid22, '%%type of detector motion:=step and shoot\n');
            fprintf( fid22, '\n');
            fprintf( fid22, '%%DATA MATRIX DESCRIPTION:=\n');
            fprintf( fid22, 'number of time frames:=%i\n', nframes);
            fprintf( fid22, '%%number of horizontal bed offsets:=1\n');
            fprintf( fid22, 'number of time windows:=1\n');
            fprintf( fid22, '%%number of emission data types:=2\n');
            fprintf( fid22, '%%emission data type description [1]:=prompts\n');
            fprintf( fid22, '%%emission data type description [2]:=randoms\n');
            fprintf( fid22, '%%number of transmission data types:=0\n');
            fprintf( fid22, '%%scan direction:=out\n'); % Richard needed to check this.  Is it always the case?
            fprintf( fid22, '\n');
            fprintf( fid22, '%%DATA SET DESCRIPTION:=\n');
            fprintf( fid22, '!total number of data sets:=%i\n', nframes);            
            for iframes = 1:nframes
                offset   = 30 + (iframes-1)*1000000;
                files    = [fbase strtrim(sprintf('%3.3i', iframes-1)) '.s'];
                fileshdr = [files '.hdr'];
                fprintf( fid22, '%data set [%i]:={%i,%s,%s}\n', iframes, offset, fileshdr, files);
            end            
            fprintf( fid22, '\n');
            fclose(  fid22);            
        end
        function this = savingData(this)
            this.dprintf('savingData', sprintf('Number of Prompts     = %i\n', this.nbprt));
            this.dprintf('savingData', sprintf('Number of Randoms     = %i\n', this.nbrnd));
            this.dprintf('savingData', sprintf('Number of Time Tags   = %i\n', this.nbttag));
            this.dprintf('savingData', sprintf('Number of Physio Tags = %i\n', this.nbphy));
            this.dprintf('savingData', sprintf('Number of Control Acq = %i\n', this.nbctrl));
            
            if (this.saveSino)
                for ibb = 1:this.nbins
                    fileout = fullfile(this.dir0, [this.studyName strtrim(sprintf('%3.3i', ibb-1)) '.s']);
                    this.fqfilename = fileout;
                    
                    fid30 = fopen(fileout, 'w');
                    this.dprintf('savingData', sprintf('Writing sinogram :%s', fileout));                    
                    prompts_ = this.prompts((ibb-1)*this.sinoNumel+1:ibb*this.sinoNumel);
                    randoms_ = this.randoms((ibb-1)*this.sinoNumel+1:ibb*this.sinoNumel);
                    fwrite(fid30, prompts_);
                    fwrite(fid30, randoms_);
                    fclose(fid30);
                    
                    this.fduration = this.tickperbin(ibb);                    
                    fileouthdr = [this.dir0 this.studyName strtrim(sprintf('%3.3i', ibb-1)) '.s.hdr'];
                    this.save_hdr( fileouthdr, fileout, this.listmode.studyTime, ...
                        this.total(prompts_), this.total(randoms_));
                    this.fstart = this.fstart + this.fstartinc;
                    if (ibb == 1)
                        this.save_mhdr(this.studyName, this.nbins);
                    end
                    fclose(fid30);
                end % end loop on bins
            end % end if saving sinograms
        end
        
 		function this = SortLMMotionMatlab(varargin)
 			%% SORTLMMOTIONMATLAB
 			%  Usage:  this = SortLMMotionMatlab()
            
            ip = inputParser;
            addParameter(ip, 'dir0', '/data/anlab/Hongyu/Phantom_24Jan2017/Gated', @isdir);
            addParameter(ip, 'fileMRbin', 'BinningResult.txt', @ischar);
            addParameter(ip, 'filePETbin', 'PETMR_bintable_JJL.dat', @ischar);
            addParameter(ip, 'fileprefixPTD', 'Motion-LM-00', @ischar);
            addParameter(ip, 'nbins', 5, @isnumeric);
            addParameter(ip, 'saveSino', false, @islogical);
            addParameter(ip, 'studyName', 'Phantom5BinsG_JJL_', @ischar);
            addParameter(ip, 'tstep', 170, @(x) isnumeric && x >= 85);
            parse(ip, varargin{:});
 			this.dir0_ = ip.Results.dir0;
            this.fileprefixPTD_ = ip.Results.fileprefixPTD;
            this.nbins = ip.Results.nbins;
            this.saveSino = ip.Results.saveSino;
            this.studyName_ = ip.Results.studyName;
            this.tstep = ip.Results.tstep;        
            
            cd(this.dir0);
            import mlan.*;
            this.mrBinning_  = MRBinningParser.load(ip.Results.fileMRbin, 'tstep', ip.Results.tstep);
            this.petBinning_ = PETBinningParser.new(ip.Results.filePETbin);
            this.listmode_   = Listmode('filepath', this.dir0_, 'fileprefix', ip.Results.fileprefixPTD);            
            this.xsize       = this.listmode_.lhdrParser.parseSplitNumeric('bin size (cm)');
            this.zsize       = this.listmode_.lhdrParser.parseSplitNumeric('distance between rings (cm)')/2;   
            
            this.minindL = this.long(3000);
            this.maxindL = this.long(0);
            
        end
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        amax
        amin
        fduration
        fstart = 0   
        fstartinc = 10000 % 5 sec frames? 10 sec?
        maxindL
        minindL
        prompts
        randoms
        rates
        singles_rates  
        sinoinfo
        tickperbin
        timepos
        tstart0
        tvecMR
        tvecPT
        xsize
        zsize        
    end
        
    methods (Access = protected)        
        function frame_time = inc_ftime(this, frame_time)
            %% INC_FTIME increments frame time by the frame duration as needed for dynamic scan.
            %  @params frame_time has format 'HH:MM:SS'.
            
            ip = inputParser;
            addRequired(ip, 'frame_time', @(x) ~isnat(datetime(x)));
            parse(ip, frame_time);
            
            tk1 = strsplit(frame_time, ':');
            this.dprintf('inc_ftime', tk1);
            hr1 = fix(str2double(tk1(0)));
            mn1 = fix(str2double(tk1(1)));
            sc1 = fix(str2double(tk1(2))); 
            fdr = fix(str2double(this.fduration)/1000); % in sec, single
            % Richard:  this will add 0 in fdr < 1.  !
            % I am not sure if this is needed or not.
            % will need ot revise at some point.
            sc1 = sc1 + fdr;
            if (sc1 >= 60)
                mn1 = mn1 + 1;
                sc1 = sc1 - 60;
            end
            if (mn1 >= 60)
                hr1 = hr1 + 1;
                mn1 = mn1 - 60;
            end
            frame_time = sprintf('%2.2i:%2.2i:%2.2i', hr1, mn1, sc1);            
        end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        dir0_
        fileprefixPTD_
        listmode_
        mrBinning_
        petBinning_
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
            this.dprintf('SortLM_motion', 'Sinogram data = %g %g %g %g %g %g %g %g', ...
                this.listmode.xdim, this.listmode.ydim, this.listmode.zdim, this.xsize, this.zsize, ...
                this.listmode.nsegments, this.listmode.number_of_rings, this.listmode.max_ring_difference);
            this.dprintf('SortLM_motion', 'Segtable = %s', num2str(this.listmode.segtable));            
            this.dprintf('SortLM_motion', 'Allocating memory, sinoNumel(bytes) = %i', this.sinoNumel);
            this.prompts       = zeros(this.sinoNumel*this.nbins, 1, 'uint16');
            this.randoms       = zeros(this.sinoNumel*this.nbins, 1, 'uint16');
            this.singles_rates = zeros(this.listmode.nbuckets,1, 'uint32');
            this.tickperbin    = zeros(this.nbins,1, 'uint32');
            this.nbprt  = this.long(0);
            this.nbrnd  = this.long(0);
            this.nbttag = this.long(0);
            this.nbphy  = this.long(0);
            this.nbctrl = this.long(0);
            
            %
            % Setup this.mrBinning_
            %
            %this.mrBinning_ = this.mrBinning_.setIbinTo100;
            this.fduration = this.mrBinning_.TFinal - this.mrBinning_.tstart;
            this.tvecMR = zeros(this.TVEC_DIM, 1, 'uint16');
            this.tvecPT = zeros(this.TVEC_DIM, 1, 'uint16');
            this.fstart = this.mrBinning_.tstart;
            this.tstart0 = this.mrBinning_.tstart;
            
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
                    
                    tagPacketBitL   = bitshift(arrayL(ifl), -31, 'uint32'); 
                    tagTimeMarkerL  = bitshift(arrayL(ifl), -30, 'uint32'); 
                    tagPhysioL      = bitshift(arrayL(ifl), -28, 'uint32'); 
                    
                    %% prompts or randoms
                    if (tagPacketBitL == 0 && this.mrBinning_.hasTimeMarker)
                        
                        % lots of small local variables ...
                        prtL  = bitshift(arrayL(ifl), -30, 'uint32');
                        addrL = bitand(arrayL(ifl), this.hex2long('1FFFFFFF'), 'uint32');
                        izpL  = addrL/(this.listmode.xdim*this.listmode.ydim);
                        ivwL  = (addrL - izpL*this.listmode.xdim*this.listmode.ydim)/ this.listmode.xdim;
                        iprL  = (addrL - izpL*this.listmode.xdim*this.listmode.ydim - ivwL*this.listmode.xdim);
                        indL  = iprL;  %(iprL-this.listmode.xdim/2)*2+this.listmode.xdim/2
                        
                        this.minindL = min(indL, this.minindL);
                        this.maxindL = max(indL, this.maxindL);
                        
                        if (addrL <= this.sinoNumel)
                            % this.nbins limited by available physical memory ~ 5
                            if (prtL == 1 && this.mrBinning_.ibin < this.nbins)
                                this.prompts(this.mrBinning_.ibin*this.sinoNumel+addrL) = this.prompts(this.mrBinning_.ibin*this.sinoNumel+addrL) + 1;
                                this.nbprt = this.nbprt + 1;
                                
                                %% CUT in vertical position
                                if (abs(ivwL-120) <= 10)
                                    this.petBinning_.avgpos = this.petBinning_.avgpos + single(indL);
                                    this.petBinning_.nbpos  = this.petBinning_.nbpos + 1;
                                end
                            end
                            if (prtL == 0 && this.mrBinning_.ibin < this.nbins)
                                this.randoms(this.mrBinning_.ibin*this.sinoNumel+addrL) = this.randoms(this.mrBinning_.ibin*this.sinoNumel+addrL) + 1;
                                this.nbrnd = this.nbrnd + 1;
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
                            
                            this.petBinning_.time = bitand(arrayL(ifl), this.hex2long('1FFFFFFF'), 'uint32'); %% in msec
                            this.nbttag = this.nbttag + 1;
                            
                            %this.dprintf('SortLM_motion', 'Running time = %g %g %g %i %g', tag, this.petBinning_.time, this.petBinning_.frame_time, this.mrBinning_.hasTimeMarker, frame_duration)
                            if (this.mrBinning_.hasTimeMarker && this.mrBinning_.ibin < this.nbins)
                                this.tickperbin(this.mrBinning_.ibin) = this.tickperbin(this.mrBinning_.ibin) + 1; 
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
                                    this.savingData;
                                    this.plot;
                                    fclose(fid33);
                                    return
                                end
                                if (~isnan(this.mrBinning_.ibin))
                                    if (this.mrBinning_.ibin >= this.nbins)
                                        error('mlan:counterErr', 'bin number is too large!\n%g\n', this.mrBinning_.ibin);
                                    end
                                    this.mrBinning_ = this.mrBinning_.setIbin0;
                                    %dprintf('SortLM_motion', 'Current Bin time = %g %g %i %i %g %i %i', ...
                                    %this.mrBinning_.tstart, this.mrBinning_.tlast, this.mrBinning_.ibin, this.mrBinning_.ibin, this.petBinning_.frame_time, this.mrBinning_.hasTimeMarker, this.mrBinning_.ibin0);
                                    %dprintf('SortLM_motion', '%10i %10i %10i %10i %10i %10i', ...
                                    %this.tickperbin(0:this.nbins-1), this.long(this.total(this.tickperbin)));
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
                                this.savingData;
                                this.plot
                                fclose(fid33);
                                return
                            end
                            
                        end %% Time tags
                        
                        %% Singles data
                        if (tagGantryL == 5)
                            block   = bitand(bitshift(arrayL(ifl), -19, 'uint32'), this.hex2long('3FF'), 'uint32');
                            singles = bitand(arrayL(ifl), this.hex2long('7FFFF'), 'uint32');
                            %this.dprintf('SortLM_motion', 'Block and singles #s.... %i %i', block, singles
                            if (block < this.listmode.nbuckets)
                                this.singles_rates(block) = singles;
                            end
                        end
                        
                    end % of ttag = 2
                    
                    %% Physio triggers -- TAG3
                    if (tagPhysioL == 14)
                        this.dprintf('SortLM_motion', 'Physio trigger format# %i', ...
                            bitand(bitshift(arrayL(ifl), -24, 'uint32'), this.hex2long('0F'), 'uint32'));
                        this.dprintf('SortLM_motion', '%8i     %32bx\n', this.petBinning_.time, arrayL(ifl));
                        this.nbphy = this.nbphy + 1;
                    end                    
                    if (tagPhysioL == 15)
                        this.dprintf('SortLM_motion', 'Control acquisition parameters# %i %8i\n', ...
                            bitand(bitshift(arrayL(ifl), -24, 'uint32'), this.hex2long('0F'), 'uint32'), this.petBinning_.time);
                        %this.dprintf('SortLM_motion', '%8i .  %32bx', this.petBinning_.time, arrayL(ifl));
                        this.nbctrl = this.nbctrl + 1;
                    end
                    
                end %% Loop within buffer block
                
            end %% Loop buffer blocks         
            
            this = this.savingData;
            this.plot;  
            fclose(fid33);
        end        
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

