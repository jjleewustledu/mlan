classdef PETBinningParser < mlan.AbstractParser
	%% PETBINNINGPARSER  

	%  $Revision$
 	%  was created 20-Jun-2017 00:37:06 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlsiemens/src/+mlsiemens.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
    
    properties (Constant)      
        PET_TIME_DILATION = 1.00502512563 % this factor accounts for the fact that the PET clock runs a bit slower
    end
    
    properties 
        avgpos
        nbpos
        time = 0
        tlast
        tstart = 0
        tstep  = 10000 % 10 sec
    end
    
    properties (Dependent)
        frame_time
    end
    
	methods (Static)
        function this = load(fn)
            assert(lexist(fn, 'file'));
            [pth, fp, fext] = fileparts(fn); 
            if (lstrfind(fext, mlan.PETBinningParser.FILETYPE_EXT) || ...
                isempty(fext))
                this = mlan.PETBinningParser.loadText(fn); 
                this.filepath_   = pth;
                this.fileprefix_ = fp;
                this.filesuffix_ = fext;
                return 
            end
            error('mlan:unsupportedParam', 'PETBinningParser.load does not support file-extension .%s', fext);
        end
        function loadx(~)
            error('mlan:notImplemented', 'PETBinningParser.loadx');
        end
        function this = new(fn)
            [pth, fp, fext] = fileparts(fn); 
            if (lexist(fn, 'file'))
                movefile(fn, fullfile(pth, [fp '_backup' mydatetimestr(now) fext]));
            end
            if (lstrfind(fext, mlan.PETBinningParser.FILETYPE_EXT) || ...
                isempty(fext))
                this = mlan.PETBinningParser;
                this.fid_ = fopen(fn, 'w'); 
                this.filepath_   = pth;
                this.fileprefix_ = fp;
                this.filesuffix_ = fext;
                return 
            end
            error('mlan:unsupportedParam', 'PETBinningParser.new does not support file-extension .%s', fext);
        end
    end
    
	methods 		 
        
        %% GET
        
        function g = get.frame_time(this)
            g = single(this.time)/this.PET_TIME_DILATION;
        end
                
        %%
        
        function fprintf(this, varargin)
            fprintf(this.fid, varargin{:});
        end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
    end
    
    methods (Static, Access = 'protected')
        function this = loadText(fn)
            import mlan.*;
            this = PETBinningParser;
            this.cellContents_ = PETBinningParser.textfileToCell(fn);
        end
    end
    
    methods (Access = 'protected')        
        function this = PETBinningParser(varargin)
            this.avgpos = 0;
            this.nbpos  = 0;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

