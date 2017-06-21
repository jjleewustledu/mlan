classdef MRBinningParser < mlan.AbstractParser
	%% MRBINNINGPARSER  

	%  $Revision$
 	%  was created 19-Jun-2017 22:16:05 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	

    properties (Constant)
        TSTEP_MIN = 85 % msec
    end
    
    properties (Dependent)
        ibin
        nmarkers
        TFinal
        timepos
        tlast
        tstart
        tstep
    end
    
	methods (Static)
        function this = load(fn)
            assert(lexist(fn, 'file'));
            [pth, fp, fext] = fileparts(fn); 
            if (lstrfind(fext, mlan.MRBinningParser.FILETYPE_EXT) || ...
                isempty(fext))
                this = mlan.MRBinningParser.loadText(fn); 
                this.filepath_   = pth;
                this.fileprefix_ = fp;
                this.filesuffix_ = fext;
                return 
            end
            error('mlan:unsupportedParam', 'MRBinningParser.load does not support file-extension .%s', fext);
        end
        function this = loadx(fn, ext)
            if (~lstrfind(fn, ext))
                if (~strcmp('.', ext(1)))
                    ext = ['.' ext];
                end
                fn = [fn ext];
            end
            assert(lexist(fn, 'file'));
            [pth, fp, fext] = filepartsx(fn, ext); 
            this = mlan.MRBinningParser.loadText(fn);
            this.filepath_   = pth;
            this.fileprefix_ = fp;
            this.filesuffix_ = fext;
        end
    end
    
	methods 		 
        
        %% GET
        
        function g = get.ibin(this)
            g = this.long(this.ibin_);
        end
        function g = get.nmarkers(this)
            g = this.long(length(this.cellContents_));
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
            while (isnan(this.ibin_) && this.currentLine_ < length(this))
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
        
        function this = MRBinningParser
            this.currentLine_ = 0;
            this.tstep_ = this.TSTEP_MIN;
        end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        currentLine_
        ibin_
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
            this.TFinal_ = names.tlast;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

