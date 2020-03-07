classdef MRBinningParser < mlan.AbstractParser
	%% MRBINNINGPARSER  

	%  $Revision$
 	%  was created 19-Jun-2017 22:16:05 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	

    properties (Constant)
        TSTEP_MIN = 85 % msec
    end
    
    properties
       hasTimeMarker 
    end
    
    properties (Dependent)
        ibin
        ibin0
        nmarkers
        TFinal
        timepos
        tlast
        tstart
        tstep
    end
    
	methods (Static)
        function this = load(fn, varargin)
            import mlan.*;
            ip = inputParser;
            addRequired(ip, 'fn', @(x) lexist(x, 'file'));
            addParameter(ip, 'tstep', MRBinningParser.TSTEP_MIN, @isnumeric);
            parse(ip, fn, varargin{:});
            
            [pth, fp, fext] = fileparts(fn); 
            if (lstrfind(fext, MRBinningParser.FILETYPE_EXT) || ...
                isempty(fext))
                this = MRBinningParser.loadText(fn); 
                this.filepath_   = pth;
                this.fileprefix_ = fp;
                this.filesuffix_ = fext;            
                this.tstep_ = ip.Results.tstep;
                if (this.hasNext)
                    this = this.next;
                    this.ibin0_ = this.ibin_;
                end
                this.hasTimeMarker = true;
                return 
            end
            error('mlan:unsupportedParam', 'MRBinningParser.load does not support file-extension .%s', fext);
        end
        function loadx(~)
            error('mlan:notImplemented', 'MRBinningParser.loadx');
        end
        function obj = ulong(obj)
            %% ULONG always returns 4-byte integers (uint32)
            obj = mlan.Listmode.ulong(obj);
        end
    end
    
	methods 		 
        
        %% GET
        
        function g = get.ibin(this)
            g = this.ulong(this.ibin_);
        end
        function g = get.ibin0(this)
            g = this.ulong(this.ibin0_);
        end
        function g = get.nmarkers(this)
            g = this.ulong(length(this.cellContents_));
        end
        function g = get.TFinal(this)
            g = this.TFinal_;
        end
        function g = get.tlast(this)
            g = this.tlast_;
        end
        function g = get.timepos(this)
            g = this.timepos_;
        end
        function g = get.tstart(this)
            g = this.tstart_;
        end
        function g = get.tstep(this)
            g = this.tstep_;
        end        
        
        function this = set.tstep(this, s)
            assert(isnumeric(s) && s >= this.TSTEP_MIN);
            this.tstep_ = s;
        end
        
        %%
        
        function tf   = hasNext(this)
            tf = this.currentLine_ < length(this);
        end
        function this = next(this)  
            this.tstart_ = nan;
            this.tlast_  = nan;
            this.ibin_   = nan;
            while (isnan(this.ibin_) && this.currentLine_ < length(this.cellContents_))
                this.currentLine_ = this.currentLine_ + 1;
                names = regexp( ...
                    this.cellContents_{this.currentLine_}, ...
                    sprintf('[(?<tstart>\\d+) ms, (?<tlast>\\d+) ms) --> Bin (?<ibin>\\d+$)'), 'names');
                if (~isempty(names))
                    this.tstart_ = str2double(names.tstart);
                    this.tlast_  = str2double(names.tlast);
                    this.ibin_   = str2double(names.ibin);
                end
            end
        end
        function bn   = parseAssignedBin(this, t1, t2)
            t1 = fix(t1);
            t2 = fix(t2);
            line = this.findFirstCell(sprintf('[%i ms, %i ms) -->', t1, t2));
            names = regexp(line, sprintf('[%i ms, %i ms) --> Bin (?<binNum>\\d+$)', t1, t2), 'names');
            if (~isempty(names))
                bn = str2double(names.binNum);
            else
                bn = nan;
            end
        end   
        function this = resetIbin(this)
            this.ibin_ = this.ibin0_;
            this.hasTimeMarker = true;
        end
        function this = setIbin0(this)
            this.ibin0_ = this.ibin_;            
            this.hasTimeMarker = true;
        end
        function this = setIbinTo100(this)
            this.ibin_ = 100;
        end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        currentLine_
        ibin_
        ibin0_
        TFinal_
        timepos_
        tlast_
        tstart_
        tstep_
    end
    
    methods (Static, Access = 'protected')
        function this = loadText(fn)
            import mlan.*;
            this = MRBinningParser;
            this.cellContents_ = MRBinningParser.textfileToCell(fn);         
            names = regexp( ...
                this.cellContents_{length(this)}, ...
                sprintf('[(?<tstart>\\d+) ms, (?<tlast>\\d+) ms) --> Bin (?<ibin>\\d+$)'), 'names');
            this.TFinal_ = str2double(names.tlast);
        end
    end
    
    methods (Access = 'protected')        
        function this = MRBinningParser
            this.currentLine_ = 0;
            this.tstep_ = this.TSTEP_MIN;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

