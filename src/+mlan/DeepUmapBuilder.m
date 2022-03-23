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

        function ic = buildUmap(this, varargin)
            %  Returns:
            %      ic: umap temporally closest to scan, registered to T1001, located in this.sessionData.scanPath.

            pwd0 = pushd(this.sessionData.scanPath);

            umap = this.sessionData.deepumap('typ', 'mlfourd.ImagingContext2');
            umap.selectFourdfpTool();
            umap.fqfileprefix = fullfile(this.sessionData.umapPath, 'deepumap');
            if ~isfile(umap.fqfn); umap.save(); end

            mpr = this.sessionData.T1001('typ', 'mlfourd.ImagingContext2');
            mpr.selectFourdfpTool();
            if ~isfile(mpr.fqfn); mpr.save(); end

            umap_on_mpr= this.buildVisitor.CT2mpr_4dfp(mpr.fqfp, umap.fqfp);
            ic = mlfourd.ImagingContext2(umap_on_mpr);
            ic.selectFourdfpTool();

            popd(pwd0)
        end
        function this = prepareMprToAtlasT4(this)
            %% PREPAREMPRTOATLAST4
            %  @param this.sessionData.{mprage,atlas} are valid.
            %  @return this.product_ := [mprage '_to_' atlas '_t4'], existing in the same folder as mprage.
            %  TODO:  return fqfn t4.
            
            s = this.sessionData;
            t4 = [              s.mprage('typ', 'fp') '_to_' s.atlas('typ', 'fp') '_t4'];            
            if ~isfile(fullfile(s.mprage('typ', 'path'), t4)) && ~this.sessionData.noclobber
                pwd0 = pushd(   s.mprage('typ', 'path'));
                this.buildVisitor.msktgenMprage(s.mprage('typ', 'fp'));
                popd(pwd0);
            end
            this.product_ = t4;
        end
        function teardownBuildUmaps(this)
            this.teardownLogs;
            this.teardownT4s;
            this.finished.markAsFinished( ...
                'path', this.logger.filepath, 'tag', [this.finished.tag '_' myclass(this) '_teardownBuildUmaps']); 
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
