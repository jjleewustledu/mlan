classdef Ccir993
    %% CCIR993 provides high-level organization of all automations associated with CCIR Project 993.
    %  
    %  Created 30-Jun-2022 13:50:54 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.12.0.1956245 (R2022a) Update 2 for MACI64.  Copyright 2022 John J. Lee.
    
    properties
        rawdata_dir
        session_dir
        subject_dir
    end
       
    methods
        function this = Ccir993(varargin)
            %% CCIR993 
            %  Args:
            %      session_dir (folder): containing \w+_DT\d{14}.000000-Converted-(NAC|AC)
            %      rawdata_dir (folder): containing *.dcm, *.bf from CNDA.
            
            ip = inputParser;
            addParameter(ip, "session_dir", [], @isfolder)
            addParameter(ip, "subject_dir", [], @isfolder)
            addParameter(ip, "rawdata_dir", [], @isfolder)
            addParameter(ip, "chmod", false, @islogical)
            parse(ip, varargin{:})
            ipr = ip.Results;
            this.session_dir = ipr.session_dir;
            this.subject_dir = ipr.subject_dir;

            if ipr.chmod
                try
                    mlbash(sprintf('chmod -R 777 %s', this.session_dir))
                catch
                end
            end
            if isempty(ipr.rawdata_dir)
                ipr.rawdata_dir = fullfile(this.session_dir, 'rawdata');
            end
            this.rawdata_dir = ipr.rawdata_dir;
        end

        function call(this)
            %mlan.Ccir993Bids.create_tracer_folders(this.rawdata_dir);
            %mlan.TracerDirector2.construct_niftypet2(this.session_dir);

            if ~isfolder(fullfile(this.session_dir, 'mri', ''))
                mri_dir = glob(fullfile(this.session_dir, '*freesurfer*', 'DATA', '*', 'mri'));
                assert(~isempty(mri_dir))
                mlbash(sprintf('ln -s %s', mri_dir{1}))
            end

            %% not attenuation corrected ------------------------------

            nacs = globFolders(fullfile(this.session_dir, '*_DT*-Converted-NAC'))';
            nacs = nacs(~contains(nacs, 'FDG'));
            parfor ni = 1:length(nacs)
                director = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                director.step0();
            end
            for ni = 1:length(nacs)
                director = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                director.step_dynamic();
            end
            parfor ni = 1:length(nacs)
                director = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                director.step_resolve();  
            end

            %% attenuation corrected --------------------------------

            acs = globFolders(fullfile(this.session_dir, '*_DT*-Converted-AC'))';
            acs = acs(~contains(acs, 'FDG'));
            for ai = 1:length(acs)
                director = mlan.TracerDirector2.constructFromScanPath(acs{ai});
                director.step_dynamic();
            end
            parfor ai = 1:length(acs)
                director = mlan.TracerDirector2.constructFromScanPath(acs{ai});
                director.step_resolve();  
            end
        end
        function call0(this)
            if ~isfolder(fullfile(this.session_dir, 'mri', ''))
                mri_dir = glob(fullfile(this.session_dir, '*freesurfer*', 'DATA', '*', 'mri'));
                assert(~isempty(mri_dir))
                mlbash(sprintf('ln -s %s', mri_dir{1}))
            end

            %% not attenuation corrected ------------------------------

            nacs = globFolders(fullfile(this.session_dir, '*_DT*-Converted-NAC'))';
            nacs = nacs(~contains(nacs, 'FDG'));
            parfor ni = 1:length(nacs)
                director = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                director.step0();
            end
        end
        function call2(this)

            %% not attenuation corrected ------------------------------

            nacs = globFolders(fullfile(this.session_dir, '*_DT*-Converted-NAC'))';
            nacs = nacs(~contains(nacs, 'FDG'));
            parfor ni = 1:length(nacs)
                director = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                director.step_resolve();  
            end
        end
        function call3(this)
            %% expects *-Converted-AC containing multi-frame umapSynth.nii.gz

            %% attenuation corrected ------------------------------

            acs = globFolders(fullfile(this.session_dir, '*_DT*-Converted-AC'))';
            acs = acs(~contains(acs, 'FDG'));
            for ai = 1:length(acs)
                director = mlan.TracerDirector2.constructFromScanPath(acs{ai});
                director.step_dynamic();
            end
        end
        function call4(this)

            %% attenuation corrected ------------------------------

            acs = globFolders(fullfile(this.session_dir, '*_DT*-Converted-AC'))';
            acs = acs(~contains(acs, 'FDG'));
            parfor ai = 1:length(acs)
                director = mlan.TracerDirector2.constructFromScanPath(acs{ai});
                director.step_resolve();  
            end
        end
        function phantom = call_phantom(this, varargin)
            %% registers ct-mu of nalgene bottle to MRAC in umap/DICOM,
            %  then reconstructs emissions with aligned ct-mu.
            %  Args:
            %      UMAP (any): [] builds UMAP from umap/DICOM; any builds ImagingContext2 as target for flirt of ct-mu.

            ip = inputParser;
            addParameter(ip, 'UMAP', []);
            parse(ip, varargin{:});
            ipr = ip.Results;
            
            if isempty(ipr.UMAP)
                % build MRAC UMAP, which is already aligned with emissions
                [~,r] = mlpipeline.Bids.dcm2niix('umap/DICOM', 'f', 'umapdt%t');
                UMAP = regexp(r, 'umapdt\d{14}\S+.nii', 'match');
                UMAP = strcat(UMAP{1}, '.gz');
                UMAP = mlfourd.ImagingContext2(UMAP);
                UMAP = UMAP.blurred(4.3);
                UMAP.save();
            else
                UMAP = mlfourd.ImagingContext2(ipr.UMAP);
            end

            nalgene = mlfourd.ImagingContext2( ...
                fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00993', 'rawdata', 'umapSynth_690mL_b43_float32.nii.gz'));
            template = mlfourd.ImagingContext2( ...
                fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00993', 'rawdata', 'umapTemplate.nii.gz'));

            nacs = globFolders(fullfile(this.session_dir, '*_DT*-Converted-*AC'))';
            nacs = nacs(contains(nacs, 'FDG'));
            for ni = 1:length(nacs)

                % rename NAC to AC
                if contains(nacs{ni}, '-NAC')
                    nac_ = nacs{ni};
                    nacs{ni} = strrep(nac_, '-Converted-NAC', '-Converted-AC');
                    movefile(nac_, nacs{ni});
                end

                pwd0 = pushd(nacs{ni});
                director = mlan.TracerDirector2.constructFromScanPath(pwd);

                % register nalgene to UMAP
                f = mlfsl.Flirt( ...
                    'in', nalgene.fqfn, ...
                    'out', 'nalgene_on_UMAP.nii.gz', ...
                    'ref', UMAP.fqfn, ...
                    'dof', 6, ...
                    'cost', 'mutualinfo');
                f.flirt();

                % resize nalgene; rename to umapSynth; ensure float32
                cmd = sprintf( ...
                    'reg_resample -ref %s -flo nalgene_on_UMAP.nii.gz -res umapSynth.nii.gz', ...
                    template.fqfn);
                mlbash(cmd);
                cmd = sprintf('fslmaths umapSynth.nii.gz umapSynth.nii.gz -odt float');
                mlbash(cmd);

                % reconstruct emissions
                director.step_phantom();
                g = glob('output/PET/single-frame/a_t-*_createPhantom.nii.gz');
                phantom = mlfourd.ImagingContext2(g{1});
                phantom.selectNiftiTool();
                phantom.filepath = pwd;
                phantom.fileprefix = 'phantom';
                phantom = phantom.blurred(4.3);
                phantom.save();

                % build mask for phantom
                msk = phantom.threshp(0.75);
                msk = msk.binarized();
                msk.save();
                
                % sample masked phantom
                sample = single(phantom);
                sample = sample(logical(msk));
                voxvol = prod(phantom.imagingFormat.mmppix)/1000;
                fprintf('mlan.Ccir993.call_phantom:\n');
                fprintf('\tROI mean activity = %g Bq/mL\n', mean(sample));
                fprintf('\tROI std activity  = %g Bq/mL\n', std(sample));
                fprintf('\tROI VOLUME        = %g mL\n', dipsum(msk)*voxvol);
                fprintf('\tROI VOXELS        = %g\n', dipsum(msk));
                fprintf('\tROI MIN           = %g Bq/mL\n', min(sample));
                fprintf('\tROI MAX           = %g Bq/mL\n', max(sample));
                g1 = glob('output/PET/*.json');
                disp(fileread(g1{1}));

                popd(pwd0);
            end
        end
        function call_metab(this)
            assert(isfolder(this.subject_dir));

            pwd0 = pushd(this.subject_dir);
            mlan.QuadraticAerobicGlycolysisKit.construct( ...
                'cbf', ...
                'subjectsExpr', basename(this.subject_dir));
            mlan.QuadraticAerobicGlycolysisKit.construct( ...
                'cbv', ...
                'subjectsExpr', basename(this.subject_dir));
            mlan.QuadraticAerobicGlycolysisKit.construct( ...
                'cmro2', ...
                'subjectsExpr', basename(this.subject_dir));
            popd(pwd0);
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
