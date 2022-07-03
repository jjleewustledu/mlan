classdef Ccir993
    %% CCIR993 provides high-level organization of all automations associated with CCIR Project 993.
    %  
    %  Created 30-Jun-2022 13:50:54 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.12.0.1956245 (R2022a) Update 2 for MACI64.  Copyright 2022 John J. Lee.
    
    properties
        rawdata_dir
        session_dir
    end
       
    methods
        function this = Ccir993(varargin)
            %% CCIR993 
            %  Args:
            %      session_dir (folder): containing \w+_DT\d{14}.000000-Converted-(NAC|AC)
            %      rawdata_dir (folder): containing *.dcm, *.bf from CNDA.
            
            ip = inputParser;
            addParameter(ip, "session_dir", [], @isfolder)
            addParameter(ip, "rawdata_dir", [], @isfolder)
            parse(ip, varargin{:})
            ipr = ip.Results;
            this.session_dir = ipr.session_dir;
            try
                mlbash(sprintf('chmod -R 777 %s', this.session_dir))
            catch ME
                handwarning(ME);
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
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
