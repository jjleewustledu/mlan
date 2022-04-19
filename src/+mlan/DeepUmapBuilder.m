classdef DeepUmapBuilder < mlfourdfp.AbstractSessionBuilder
    %% line1
    %  line2
    %  
    %  Created 18-Jan-2022 18:13:22 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.11.0.1837725 (R2021b) Update 2 for MACI64.  Copyright 2022 John J. Lee.
    
    methods (Static)
        function t4_resolve_umaps()
            msk = {};
            fps = {};
            for g = globT('*.nii.gz')
                ic = mlfourd.ImagingContext2(g{1});
                ic.selectFourdfpTool();
                if ~isfile(ic.filename)
                    ic.save();
                end
                fps = [fps {ic.filename}];
                bin = ic.binarized();
                if ~isfile(bin.filename)
                    bin.save();
                end
                msk = [msk {bin.filename}]; %#ok<*AGROW> 
            end

            t4r = mlfourdfp.SimpleT4ResolveBuilder('maskForImages', msk, 'theImages', fps);
            t4r.resolve();
        end
    end

    methods
        function this = DeepUmapBuilder(varargin)
            %% DEEPUMAPBUILDER 
            %  Args:
            %      census (object): provides study census data.
            %      sessionData (mlpipeline.ISessionData): is session data.
            %      buildVisitor (mlfourdfp.FourdfpVisitor): provides imaging format support.
            %      logPath (folder): prepares logger.
            %      logger (mlpipeline.ILogger): is the logger.
            %      product (any): defaults to [].
            
            this = this@mlfourdfp.AbstractSessionBuilder(varargin{:});
        end

        function umap = buildUmap(this, varargin)
            %  Returns:
            %      umap: umap temporally closest to scan, registered to T1001, 
            %            in this.sessionData.scanPath/deepumap.4dfp.hdr.

            s = this.sessionData;

            umap = s.deepumap('typ', 'mlfourd.ImagingContext2'); % temporally closest NIfTI                                                                 % 
            umap.selectFourdfpTool();
            if dipmax(umap) > 10
                umap = umap ./ 10000; % rescale to bone ~ 0.1 as expected by NiftyPET
            end
            umap.ensureSingle();
            umap.fqfp = fullfile(s.scanPath, 'umapSynth');
            umap.save(); % scanPath/deepumap.4dfp.hdr

            mpr = s.mpr('typ', 'mlfourd.ImagingContext2');
            mpr.selectFourdfpTool();
            mpr.fqfp = fullfile(s.scanPath, 'T1001');
            mpr.save(); % scanPath/T1001.4dfp.hdr

            pwd0 = pushd(s.scanPath);
            this.buildVisitor.mpr2atl_4dfp(mpr.fileprefix);
            umap_on_mpr = this.buildVisitor.CT2mpr_4dfp( ...
                mpr.fileprefix, umap.fileprefix, 'options', strcat('-T', this.atlas('typ','fqfp')));
            umap = mlfourd.ImagingContext2(umap_on_mpr);
            popd(pwd0)
        end
        function [this,t4_fqfn] = prepareMprToAtlasT4(this)
            %% PREPAREMPRTOATLAST4
            %  @param this.sessionData.{mprage,atlas} are valid.
            %  @return this.product_ := [mprage '_to_' atlas '_t4'], existing in the same folder as mprage.
            %  @return t4_fqfn.
            
            s = this.sessionData;
            t4 = strcat(s.mprage('typ', 'fp'), '_to_', s.atlas('typ', 'fp'), '_t4');
            t4_fqfn = fullfile(s.mprage('typ', 'path'), t4);
            if isfile(t4_fqfn)
                return
            end

            pwd0 = pushd(s.mprage('typ', 'path'));
            this.buildVisitor.msktgenMprage(s.mprage('typ', 'fp'));
            popd(pwd0);
            this.product_ = t4_fqfn;
        end
        function teardownBuildUmaps(this)
            this.teardownLogs;
            this.teardownT4s;
            this.finished.markAsFinished( ...
                'path', this.logger.filepath, 'tag', [this.finished.tag '_' myclass(this) '_teardownBuildUmaps']); 
        end        
        function     teardownLogs(this)
            ensuredir(this.getLogPath);
            try
                movefiles('*.log', this.getLogPath); 
                movefiles('*.txt', this.getLogPath);   
                movefiles('*.lst', this.getLogPath);    
                movefiles('*.mat0', this.getLogPath);   
                movefiles('*.sub', this.getLogPath); 
            catch ME
                dispwarning(ME, 'mlfourdfp:RuntimeWarning', ...
                    'PseudoCTBuilder.teardownLogs failed to move files into %s', this.getLogPath);
            end
        end
        function     teardownT4s(this)
            if (this.keepForensics); return; end
        end 
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
