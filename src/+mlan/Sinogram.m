classdef Sinogram < mlan.AbstractListmode
	%% SINOGRAM  

	%  $Revision$
 	%  was created 22-Jun-2017 22:10:51 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties (Dependent)
        listmode
        Nbin
        Ncontrols
        Nmonitors
        Nprompts 
        Nrandoms 
        Ntimemarks
        singlesRates
        tickPerBin
        tstart
        tstartinc
 	end

	methods 
        
        %% GET/SET
        
        function g = get.listmode(this)
            g = this.listmode_;
        end
        function g = get.Nbin(this)
            g = this.Nbin_;
        end
        function g = get.Ncontrols(this)
            g = this.Ncontrols_;
        end
        function g = get.Nmonitors(this)
            g = this.Nmonitors_;
        end
        function g = get.Nprompts(this)
            g = this.Nprompts_;
        end
        function g = get.Nrandoms(this)
            g = this.Nrandoms_;
        end
        function g = get.Ntimemarks(this)
            g = this.Ntimemarks_;
        end
        function g = get.singlesRates(this)
            g = this.singlesRates_;
        end
        function g = get.tickPerBin(this)
            g = this.tickPerBin_;
        end
        function g = get.tstart(this)
            g = this.tstart_;
        end
        function g = get.tstartinc(this)
            g = this.tstartinc_;
        end
        
        %%
        
        function this = assignSinglesRates(this, idx, val)
            this.singlesRates_(idx) = val;
        end
        function this = promptsPP(this, ibin, addr)
            this.prompts_(ibin*numel(this)+addr) = this.prompts_(ibin*numel(this)+addr) + 1;
            this.Nprompts_ = this.Nprompts_ + 1;
        end
        function this = randomsPP(this, ibin, addr)
            this.randoms_(ibin*numel(this)+addr) = this.randoms_(ibin*numel(this)+addr) + 1;
            this.Nrandoms_ = this.Nrandoms_ + 1;
        end
        function this = tickPerBinPP(this, idx)
            this.tickPerBin_(idx) = this.tickPerBin_(idx) + 1;
        end
        function n = numel(this)
            n = this.listmode.xdim*this.listmode.ydim*this.listmode.zdim;
        end
        function save(this)            
            this.dprintf('Sinogram.save', sprintf('N. of Prompts                  = %i\n', this.Nprompts));
            this.dprintf('Sinogram.save', sprintf('N. of Randoms                  = %i\n', this.Nrandoms));
            this.dprintf('Sinogram.save', sprintf('N. of Time Marker Tags         = %i\n', this.Ntimemarks));
            this.dprintf('Sinogram.save', sprintf('N. of Patient Monitoring Tags  = %i\n', this.Nmonitors));
            this.dprintf('Sinogram.save', sprintf('N. of Control Acquisition Tags = %i\n', this.Ncontrols));            

            for ibin = 1:this.Nbin                
                s = fullfile(this.filepath, [this.studyName strtrim(sprintf('%3.3i', ibin-1)) '.s']);
                this.fqfilename = s;

                fid30 = this.fopen(s, 'w');
                this.dprintf('savingData', sprintf('Writing sinogram :%s', s));                    
                prompts__ = this.prompts_((ibin-1)*numel(this)+1:ibin*numel(this));
                randoms__ = this.randoms_((ibin-1)*numel(this)+1:ibin*numel(this));
                fwrite(fid30, prompts__);
                fwrite(fid30, randoms__);
                fclose(fid30);

                shdr = fullfile(this.filepath, [this.studyName strtrim(sprintf('%3.3i', ibin-1)) '.s.hdr']);
                this.save_shdr(shdr, s, this.total(prompts__), this.total(randoms__), this.tickPerBin(ibin));
                this.tstart = this.tstart + this.tstartinc;
                if (ibin == 1)
                    this.save_mhdr(this.studyName, this.Nbin);
                end
                fclose(fid30);
            end 
        end
        function save_mhdr(this, fileprefix, Nbin)
            %% SAVE_MHDR saves a Siemens main header; if an identically named file exists, the existing file 
            %  is backed up with suffix ['_backup' mydatetimestr(now)].
            %  @params fbase is the filename base.
            %  @params nframes is numeric.
            
            ip = inputParser;
            addRequired(ip, 'fbase', @ischar);
            addRequired(ip, 'nframes', @isnumeric);
            parse(ip, fileprefix, Nbin);
            
            filemhdr = fullfile(this.filepath, [fileprefix 'sino.mhdr']);
            fid22 = this.fopen(filemhdr, 'w');            
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
            fprintf( fid22, 'number of time frames:=%i\n', Nbin);
            fprintf( fid22, '%%number of horizontal bed offsets:=1\n');
            fprintf( fid22, 'number of time windows:=1\n');
            fprintf( fid22, '%%number of emission data types:=2\n');
            fprintf( fid22, '%%emission data type description [1]:=prompts\n');
            fprintf( fid22, '%%emission data type description [2]:=randoms\n');
            fprintf( fid22, '%%number of transmission data types:=0\n');
            fprintf( fid22, '%%scan direction:=out\n'); % Richard needed to check this.  Is it always the case?
            fprintf( fid22, '\n');
            fprintf( fid22, '%%DATA SET DESCRIPTION:=\n');
            fprintf( fid22, '!total number of data sets:=%i\n', Nbin);            
            for iframes = 1:Nbin
                offset   = 30 + (iframes-1)*1000000;
                files    = [fileprefix strtrim(sprintf('%3.3i', iframes-1)) '.s'];
                fileshdr = [files '.hdr'];
                fprintf( fid22, '%data set [%i]:={%i,%s,%s}\n', iframes, offset, fileshdr, files);
            end            
            fprintf( fid22, '\n');
            fclose(  fid22);            
        end        
        function save_shdr(this, shdr, s, tprompts, trandoms, fduration)
            %% SAVE_HDR saves Siemens sinogram header
            %  @params hdrout is char.
            %  @params fileout is char.
            %  @params fduration is numeric.
            
            ip = inputParser;
            addRequired(ip, 'shdr', @ischar);
            addRequired(ip, 's', @ischar);
            addRequired(ip, 'tprompts', @isnumeric);
            addRequired(ip, 'trandoms', @isnumeric);
            addRequired(ip, 'fduration', @isnumeric);
            parse(ip, shdr, s, tprompts, trandoms, fduration);
            
            xsize = this.listmode_.lhdrParser.parseSplitNumeric('bin size (cm)');
            zsize = this.listmode_.lhdrParser.parseSplitNumeric('distance between rings (cm)')/2;
            
            this.dprintf('save_shdr', sprintf('Writing sinogram header :%s', shdr)); 
            fid34 = this.fopen(shdr, 'w');
            fprintf( fid34, '!INTERFILE:=\n');
            fprintf( fid34, '%%comment:=Created from listmode data\n');
            fprintf( fid34, '!originating system:=2008\n');
            fprintf( fid34, '%%SMS-MI header name space:=sinogram subheader\n');
            fprintf( fid34, '%%SMS-MI version number:=3.4\n');
            fprintf( fid34, '\n');
            fprintf( fid34, '!GENERAL DATA:=\n');
            fprintf( fid34, '%%listmode header file:=%s\n', sprintf(this.filepath, 'Motion-LM-00.hdr'));
            fprintf( fid34, '%%listmode data file:=%s\n', sprintf(this.filepath, 'Motion-LM-00.l'));
            fprintf( fid34, '!name of data file:=%s\n', this.basename(s));
            fprintf( fid34, '  \n');
            fprintf( fid34, '!GENERAL IMAGE DATA:=\n');
            fprintf( fid34, '%%study date (yyyy:mm:dd):=%s\n', this.listmode.studyDate);
            fprintf( fid34, '%%study time (hh:mm:ss GMT+00:00):=%s\n', this.listmode.studyTime);
            fprintf( fid34, 'isotope name:=F-18\n');
            fprintf( fid34, 'isotope gamma halflife (sec):=6586.2\n');
            fprintf( fid34, 'isotope branching factor:=1\n');
            fprintf( fid34, 'radiopharmaceutical:=FDG\n');
            fprintf( fid34, '%%tracer injection date (yyyy:mm:dd):=%s\n', this.listmode.studyDate);
            fprintf( fid34, '%%tracer injection time (hh:mm:ss GMT+00:00):=%s\n', this.listmode.stduyTime);
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
            fprintf( fid34, 'scale factor (mm/pixel) [1]:=%i\n', xsize*10.);
            fprintf( fid34, 'scale factor (degree/pixel) [2]:=%i\n', 180./this.listmode.ydim);
            fprintf( fid34, 'scale factor (mm/pixel) [3]:=%i\n', zsize*10.);
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
            fprintf( fid34, 'data offset in bytes[2]:=%i\n', numel(this)*2);
            fprintf( fid34, '\n');
            fprintf( fid34, '!IMAGE DATA DESCRIPTION:=\n');
            fprintf( fid34, '!total number of data sets:=1\n');
            fprintf( fid34, 'total prompts:=%15i\n', ip.Results.tprompts);
            fprintf( fid34, '%%total randoms:=%15i\n', ip.Results.trandoms);
            fprintf( fid34, '%%total net trues:=%i\n', ip.Results.tprompts - ip.Results.trandoms);            
            if (fix(single(ip.Results.fduration)/1000) > 2) % this one needs to be atleast 2 sec
                fprintf( fid34, '!image duration (sec):=%s\n', strtrim(string(fix(single(ip.Results.fduration)/1000))));
            else
                fprintf( fid34, '!image duration (sec):=2\n');
            end
            fprintf( fid34, '!image relative start time (sec):=%f8.1\n', single(this.tstart)/1000);
            fprintf( fid34, '%%image duration from timing tags (msec):=%i\n', ip.Results.fduration);
            fprintf( fid34, '%%GIM loss fraction:=1\n');
            fprintf( fid34, '%%PDR loss fraction:=1\n');
            fprintf( fid34, '\n');
            fprintf( fid34, '%%DETECTOR BLOCK SINGLES:=\n');
            fprintf( fid34, '%%number of buckets:=%15i\n', fix(this.listmode.nbuckets));
            fprintf( fid34, '%%total uncorrected singles rate:=%s\n', strtrim(string(8*this.total(this.singlesRates))));
            for ibuck = 1:this.listmode.nbuckets
                fprintf( fid34, '%%bucket singles rate[%s]:=%s\n', strtrim(num2str(ibuck)), strtrim(num2str(8*this.singlesRates(ibuck))));
            end            
            fprintf( fid34, '\n');
            fclose(fid34);            
        end
        function this = saveas(this, fn)
            this.fqfilename = fn;
            this.save;
        end
		  
 		function this = Sinogram(varargin)
 			%% SINOGRAM
            %  @params naemd listmode is an mlan.Listmode object.
            %  @params named Nbin is numeric ~5.  
            %  @params named noclobber is logical.
 			%  @params named numel is numeric ~354033792 .
            %  @params named studyName is char.
            %  @params named tstart is numeric ~ 2000 msec.
            %  @params named tstartinc is numeric ~ 10000 msec.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'listmode', [], @(x) isa(x, 'mlan.Listmode'));
            addParameter(ip, 'Nbin', 5, @isnumeric);
            addParameter(ip, 'noclobber', true, @islogical);
            addParameter(ip, 'studyName', strrep(class(this),'.','_'), @ischar);
            addParameter(ip, 'tstart', 0, @isnumeric); % msec
            addParameter(ip, 'tstartinc', 10000, @isnumeric); % msec
            parse(ip, varargin{:});      
            this.listmode_  = ip.Results.listmode;
            this.Nbin_      = ip.Results.Nbin;
            this.noclobber  = ip.Results.noclobber;
            this.studyName_ = ip.Results.studyName;
            this.tstart_    = ip.Results.tstart;
            this.tstartinc_ = ip.Results.tstartinc;
            
            this.Ncontrols_  = 0;
            this.Nmonitors_  = 0;
            this.Nprompts_   = 0;
            this.Nrandoms_   = 0;
            this.Ntimemarks_ = 0;
            
            this.prompts_      = zeros(numel(this)*this.Nbin, 1, 'uint16');
            this.randoms_      = zeros(numel(this)*this.Nbin, 1, 'uint16');
            this.singlesRates_ = zeros(this.listmode.nbuckets, 1, 'uint32');
            this.tickPerBin_   = zeros(this.Nbin_, 1, 'uint32');
 		end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        listmode_
        Nbin_
        Ncontrols_
        Nmonitors_
        Nprompts_
        Nrandoms_ 
        Ntimemarks_
        prompts_
        randoms_
        singlesRates_
        studyName_
        tickPerBin_
        tstart_
        tstartinc_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

