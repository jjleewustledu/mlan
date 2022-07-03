classdef TracerDirector2 < mlnipet.CommonTracerDirector
	%% TRACERDIRECTOR2 forms a builder pattern with builders configured by mlan.Ccir993Registry.

	%  $Revision$
 	%  was created 17-Nov-2018 10:26:34 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
 	 %% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    methods (Static)
        function ic2 = addMirrorUmap(ic2, sessd)
            assert(isa(ic2, 'mlfourd.ImagingContext2'))
            assert(isa(sessd, 'mlnipet.SessionData'))
            
            try
                if strcmpi(sessd.tracer, 'OO')
                    mirrorUmap = mlan.TracerDirector2.alignMirrorUmapToOO(sessd);
                    mirrorUmap.ensureSingle;
                    ic2 = ic2 + mirrorUmap;
                end
            catch ME
                handwarning(ME, 'mlnipet:RuntimeWarning', ...
                    'CommonTracerDirector.addMirrorUmap could not generate registered mirror umap')
            end   
        end
        function umap = alignMirrorUmapToOO(sessd)
            pwd0 = pushd(sessd.tracerOutputPetLocation());
            
            [OO,weights] = theOO(sessd);            
            [mirrorOnOO,umap] = prepareMirror('_facing_console', OO, weights);
            if overlap(OO, mirrorOnOO) < 0.5
                [mirrorOnOO,umap] = prepareMirror('', OO, weights);
                assert(overlap(OO, mirrorOnOO) >= 0.5)
            end            
            
            deleteExisting('mirror_*4dfp*')
            deleteExisting('*_b86*4dfp*')
            popd(pwd0)
            
            %% INTERNAL
            
            function ol = overlap(b, a)
                num = b .* a;
                a2  = a .* a;
                b2  = b .* b;
                ol  = num.dipsum/(sqrt(a2.dipsum) * sqrt(b2.dipsum));
            end
            function [mirrorOnOO,umap] = prepareMirror(tag, OO, weights)
                import mlfourd.ImagingContext2
                fv = mlfourdfp.FourdfpVisitor;
                mirror = theMirror(tag);
                fv.align_translationally( ...
                    'dest', OO.fileprefix, ...
                    'source', mirror.fileprefix, ...
                    'destMask', weights.fqfileprefix)  
                mirrorOnOO = ImagingContext2([mirror.fileprefix '_on_' OO.fileprefix '.4dfp.hdr']);
                umapSourceFp = fullfile(getenv('HARDWAREUMAPS'), ['mirror_umap_344x344x127' tag]);
                umapFp = ['mirror_umap_344x344x127_on_' OO.fileprefix];
                fv.t4img_4dfp( ...
                    [mirror.fileprefix '_to_' OO.fileprefix '_t4'], ...
                    umapSourceFp, ...
                    'out', umapFp, ...
                    'options', ['-O' OO.fileprefix])
                umap = ImagingContext2([umapFp '.4dfp.hdr']);
                umap.nifti % load into memory
            end
            function [ic2,w] = theOO(sessd)                
                import mlfourd.ImagingContext2
                w   = ImagingContext2(fullfile(getenv('HARDWAREUMAPS'), 'mirror_weights_344x344x127.4dfp.hdr'));
                ic2 = ImagingContext2(fullfile(sessd.tracerOutputPetLocation, 'OO.nii.gz'));
                ic2 = ic2.timeAveraged;
                ic2 = ic2.blurred(8.6);
                ic2 = ic2.thresh(300);
                ic2.filepath = pwd;
                ic2.filesuffix = '.4dfp.hdr';
                ic2 = ic2 .* w;
                ic2.save
            end
            function ic2 = theMirror(tag)
                ic2 = mlfourd.ImagingContext2(fullfile(getenv('HARDWAREUMAPS'), ['mirror_OO_344x344x127' tag '.4dfp.hdr']));
                ic2 = ic2.blurred(8.6);
                ic2 = ic2.thresh(300);
                ic2.filepath = pwd;
                ic2.save
            end
        end 
        function this = constructFromScanPath(fold)
            %%
            %  Args:
            %      fold (folder): e.g., '/data/anlab/jjlee/Singularity/CCIR_00993/derivatives/nipet/ses-E19850/HO_DT20200110105904.000000-Converted-NAC'

            assert(isfolder(fold));
            assert(contains(fold, 'ses-E'));
            assert(contains(fold, '-Converted-'));
            sessd = mlan.SessionData.create(fold);
            this = mlan.TracerDirector2(mlan.TracerResolveBuilder('sessionData', sessd));
        end
        function this = constructFromSessionPath(fold)
            %%
            %  Args:
            %      fold (folder): e.g., '/data/anlab/jjlee/Singularity/CCIR_00993/derivatives/nipet/ses-E19850'

            assert(isfolder(fold));
            sessd = mlan.SessionData.create(truncfile(fold, 'ses-E'));
            this = mlan.TracerDirector2(mlan.TracerResolveBuilder('sessionData', sessd));
        end
        function constructNiftypet2(varargin)
            %%
            %  Args:
            %      folders_expr (text): e.g., '/data/anlab/jjlee/Singularity/CCIR_00993/derivatives/nipet/ses-E19850'

            ip = inputParser;
            addRequired(ip, 'folders_expr', @istext);
            parse(ip, varargin{:});
            ipr = ip.Results;

            for g = globFolders(ipr.folders_expr)'

                %% not attenuation corrected ------------------------------

                nacs = globFolders(fullfile(g{1}, '*_DT*-Converted-NAC'))';
                nacs = nacs(~contains(nacs, 'FDG'));
                parfor ni = 1:length(nacs)
                    this = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                    this.step0();
                end
                for ni = 1:length(nacs)
                    this = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                    this.step_dynamic();
                end
                parfor ni = 1:length(nacs)
                    this = mlan.TracerDirector2.constructFromScanPath(nacs{ni});
                    this.step_resolve();  
                end

                %% attenuation corrected --------------------------------

                acs = globFolders(fullfile(g{1}, '*_DT*-Converted-AC'))';
                acs = acs(~contains(acs, 'FDG'));
                for ai = 1:length(acs)
                    this = mlan.TracerDirector2.constructFromScanPath(acs{ai});
                    this.step_dynamic();
                end
                parfor ai = 1:length(acs)
                    this = mlan.TracerDirector2.constructFromScanPath(acs{ai});
                    this.step_resolve();  
                end

                %% co-register all images for subject, resampling restricted
                %  see also:  constructSessionsStudy, constructSubjectsStudy

            end
        end
        function constructResolvedStudy(varargin)
            %% CONSTRUCTRESOLVEDSTUDY supports t4_resolve for niftypet.  It provides iterators for 
            %  project, session and tracer folders on the filesystem.  It provides top-level delegation for 
            %  construct_resolved().
            %  Usage:  construct_resolved(<folders experssion>[, 'ignoreFinishMark', <true|false>])
            %          e.g.:  >> construct_resolved('CCIR_00123/ses-E00123/OO_DT20190101.000000-Converted-NAC')
            %          e.g.:  >> construct_resolved('CCIR_00123/ses-E0012*/OO_DT*-Converted-NAC')
            %          e.g.:  >> construct_resolved('CCIR_00993/derivatives/nipet/ses-E03140/HO_DT20190530111122.000000-Converted-NAC')
            %
            %  @precondition s = SessionData.create();
            %  @precondition files{.bf,.dcm} in fullfile(s.sessionPath, 'LM', '')
            %  @precondition files{.bf,.dcm} in fullfile(s.sessionPath, 'norm', '')
            %  @precondition FreeSurfer recon-all results in fullfile(s.sessionPath, 'mri', '')
            %  @precondition fullfile(s.sessionPath, 'umap', '')
            %  @param foldersExpr is text.
            %  @return results in s.scanPath specified by adjustIprConstructResolvedStudy().
            %
            %  N.B.:  Setting environment vars PROJECTS_DIR or SUBJECTS_DIR is not compatible with many Docker or 
            %         Singularity use cases.
            
            import mlan.*; %#ok<NSTIMP>
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired( ip, 'foldersExpr', @ischar)
            addParameter(ip, 'ignoreFinishMark', false, @islogical);
            parse(ip, varargin{:});
            ipr = TracerDirector2.adjustIprConstructResolvedStudy(ip.Results);
            
            reg = mlan.Ccir993Registry.instance();
            for p = globT(fullfile(reg.projectsDir, ipr.projectsExpr))
                for s = globT(fullfile(p{1}, 'derivatives', 'nipet', ipr.sessionsExpr))
                    pwd0 = pushd(s{1});                    
                            
                    for t = globT(ipr.tracersExpr)
                        try
                            folders = fullfile(p{1}, 'derivatives', 'nipet', basename(s{1}), t{1});
                            sessd = SessionData.create(folders, 'ignoreFinishMark', ipr.ignoreFinishMark);
                            %if ~isfile(fullfile(sessd.umapSynthOpT1001('typ','fqfn')))
                            %    TracerDirector2.constructUmaps('sessionData', sessd, 'umapType', reg.umapType);
                            %end
                            if isempty(glob(fullfile(sessd.tracerLocation, 'umap', '*')))
                                TracerDirector2.populateTracerUmapFolder('sessionData', sessd)
                            end
                            if ~isfolder(sessd.tracerOutputLocation())
                                continue
                            end
                            
                            fprintf('constructResolvedStudy:\n');
                            fprintf([evalc('disp(sessd)') '\n']);
                            fprintf(['\tsessd.tracerLocation->' sessd.tracerLocation '\n']);
                            
                            warning('off', 'MATLAB:subsassigndimmismatch');
                            TracerDirector2.constructResolved('sessionData', sessd);
                            warning('on',  'MATLAB:subsassigndimmismatch');
                        catch ME
                            dispwarning(ME)
                            getReport(ME)
                        end
                    end
                    popd(pwd0);
                end
            end
        end
        function constructSessionsStudy(varargin)
            %% CONSTRUCTSESSIONSSTUDY
            %  @param required foldersExpr is char, e.g., 'subjects_00993/sub-S12345/ses-E12345'.
            
            import mlan.*
            import mlpet.SessionResolveBuilder
            import mlsystem.DirTool
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired( ip, 'foldersExpr', @ischar)
            addParameter(ip, 'makeClean', true, @islogical)  
            addParameter(ip, 'blur', [], @(x) isnumeric(x) || ischar(x) || isstring(x))
            addParameter(ip, 'makeAligned', true, @islogical)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            ss = strsplit(ipr.foldersExpr, '/');
            subpth = fullfile(getenv('PROJECTS_DIR'), ss{1}, ss{2});            
            
            %% redundant with mlpet.StudyResolveBuilder.configureSubjectData__ if ipr.makeClean
            if ~ipr.makeClean
                subd = SubjectData('subjectFolder', ss{2});
                subid = subFolder2subID(subd, ss{2});
                subd.aufbauSessionPath(subpth, subd.subjectsJson.(subid));
            end
            
            ensuredir(subpth)
            pwd0 = pushd(subpth);
            ensuredir(ss{end})
            dt = DirTool([ss{end} '*']);
            for ses = dt.dns
                
                pwd1 = pushd(ses{1});
                if SessionResolveBuilder.validTracerSession()
                    sessd = SessionData( ...
                        'studyData', StudyData(), ...
                        'projectData', ProjectData('sessionStr', ses{1}), ...
                        'subjectData', SubjectData('subjectFolder', ss{2}), ...
                        'sessionFolder', ses{1}, ...
                        'tracer', 'HO', 'ac', true); % referenceTracer
                    if ~isempty(ipr.blur)
                        sessd.tracerBlurArg = TracerDirector2.todouble(ipr.blur);
                    end
                    srb = SessionResolveBuilder('sessionData', sessd, 'makeClean', ipr.makeClean);
                    if ipr.makeAligned
                        srb.alignCrossModal();
                        srb.t4_mul();
                    end
                end
                popd(pwd1)
            end
            popd(pwd0)
            
            
            
            function sid = subFolder2subID(sdata, sfold)
                json = sdata.subjectsJson;
                for an_sid = asrow(fields(json))
                    if lstrfind(json.(an_sid{1}).sid, sfold(5:end))
                        sid = an_sid{1};
                        return
                    end
                end
            end
        end
        function constructSubjectsStudy(varargin)
            %% CONSTRUCTSUBJECTSSTUDY 
            %  @param required foldersExpr is char, e.g., 'subjects/sub-S12345'.
            
            import mlan.*
            import mlsystem.DirTool
            import mlpet.SubjectResolveBuilder
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'foldersExpr', @isfolder)
            addParameter(ip, 'makeClean', true, @islogical)
            addParameter(ip, 'makeAligned', true, @islogical)
            addParameter(ip, 'compositionTarget', 'subjectT1001', @ischar)
            addParameter(ip, 'blur', [], @(x) isnumeric(x) || ischar(x) || isstring(x))
            parse(ip, varargin{:})
            ipr = ip.Results;
            ss = strsplit(ipr.foldersExpr, '/');
            
            subjectPath = ipr.foldersExpr;         
            pwd0 = pushd(subjectPath);
            subd = SubjectData('subjectFolder', ss{end});
            sesf = subd.subFolder2sesFolder(ss{end});
            sessd = SessionData( ...
                'studyData', StudyData(), ...
                'projectData', ProjectData('sessionStr', sesf), ...
                'subjectData', subd, ...
                'sessionFolder', sesf, ...
                'tracer', 'HO', ...
                'ac', true); % referenceTracer
            if ~isempty(ipr.blur)
                sessd.tracerBlurArg = TracerDirector2.todouble(ipr.blur);
            end
            srb = SubjectResolveBuilder('sessionData', sessd, 'makeClean', ipr.makeClean);
            if ipr.makeAligned
                
                srb.alignCrossModal();
    
                if ~isfile(fullfile(subjectPath, 'T1001.4dfp.hdr'))
                    g = glob(fullfile(subjectPath, 'ses-E*', 'T1001.4dfp.hdr'));
                    fp = myfileprefix(g{end});
                    for x = {'.4dfp.hdr', '.4dfp.ifh', '.4dfp.img', '.4dfp.img.rec'}
                        mlbash(sprintf('ln -s %s %s', [fp x{1}], fullfile(subjectPath, ['T1001' x{1}])));
                    end
                end

                srb.workpath = fullfile(sessd.subjectPath, sessd.sessionFolder);
                srb.t4_mul();
                srb.workpath = sessd.subjectPath;
                
                %subjectSessionPath = fullfile(sessd.subjectPath, sessd.sessionFolder, '');
                %mlbash(sprintf('cp -rf %s/*.4dfp.* .', subjectSessionPath))
                %mlbash(sprintf('cp -rf %s/*_t4 .',     subjectSessionPath))
                %mlbash(sprintf('cp -rf %s/*.mat .',    subjectSessionPath))
                try
                    srb.lns_json_all();
                catch ME
                    handwarning(ME)
                end
            end
            srb.constructResamplingRestricted('compositionTarget', ipr.compositionTarget)
            popd(pwd0)
        end
        function constructSuvrStudy(varargin)
            %% CONSTRUCTSUVRSTUDY 
            %  @param required foldersExpr is char, e.g., 'subjects/sub-S12345'.
            
            import mlan.*
            
            subglob = globFoldersT(fullfile(getenv('SUBJECTS_DIR'), 'sub-S*'));
            parfor ig = 1:length(subglob)
                try
                    pwd0 = pushd(subglob{ig});

                    subFold   = basename(subglob{ig});                
                    studyData = mlan.StudyData();
                    subjData  = mlan.SubjectData('subjectFolder', subFold);                
                    sessf     = subjData.subFolder2sesFolder(subFold);
                    projData  = mlan.ProjectData('sessionStr', sessf);
                    sessData  = mlan.SessionData( ...
                        'studyData', studyData, ...
                        'projectData', projData, ...
                        'subjectData', subjData, ...
                        'sessionFolder', sessf, ...
                        'tracer', 'HO', ...
                        'ac', true);
                    tsb = mlan.TracerSuvrBuilder('sessionData', sessData);
                    tsb.buildAll()                

                    popd(pwd0)            
                catch ME
                    handwarning(ME)
                end
            end
        end
        
        function this = constructResolved(varargin)
            %  @param varargin for mlpet.TracerResolveBuilder.
            %  @return ignores the first frame of OC and OO which are NAC since they have breathing tube visible.  
            %  @return umap files generated per motionUncorrectedUmap ready
            %               for use by TriggeringTracers.js; 
            %               sequentially run FDG NAC, 15O NAC, then all tracers AC.
            %  @return mlan.TracerDirector2
                      
            this = mlan.TracerDirector2(mlan.TracerResolveBuilder(varargin{:}));
            if (~this.sessionData.attenuationCorrected)
                %this.populateTracerUmapFolder()
                if ~isfile(this.sessionData.umapSynthOpT1001)
                    this.constructUmaps(varargin{:})
                end
                this = this.instanceConstructResolvedNAC;
            else
                this = this.instanceConstructResolvedAC;
            end
        end
        function umap = constructUmaps(varargin)
            %% Constructs single volume umapSynth_on_{T1001,T1001_b43,TRIO_Y_NDC_[123]{3}}.4dfp.*
            %  in sessionData.scanPath for ~sessionData.attenuationCorrected.
            %  Args:  
            %      sessionData (mlpipeline.ISessionData): passed to builder.
            %      umapType (text): default is from mlan.Ccir993Registry.
            %      see also mlan.DeepUmapBuilder, mlfourdfp.{MRACHiresUmapBuilder, PseudoCTBuilder}
            
            import mlan.TracerDirector2;
            import mlfourd.ImagingContext2;

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'sessionData', [], @(x) isa(x, 'mlpipeline.ISessionData'))
            addParameter(ip, 'umapType', mlan.Ccir993Registry.instance().umapType, @istext)
            parse(ip, varargin{:})  
            ipr = ip.Results;

            switch ipr.umapType
                case 'deep'
                    this = TracerDirector2(mlan.DeepUmapBuilder(varargin{:}));
                    [this.builder_,t4] = this.builder.prepareMprToAtlasT4;

                    pwd0 = pushd(this.sessionData.scanPath);
                    copyfile(t4); % create scanPath/mpr_to_atl_t4
                    umap = this.builder.buildUmap;
                    umap = umap.blurred(mlsiemens.MMRRegistry.instance().petPointSpread);
                    umap.save;
                    this.builder_ = this.builder.packageProduct(umap);
                    this.builder.teardownBuildUmaps;
                    popd(pwd0);
                case 'mrac_hires'
                    this = TracerDirector2(mlfourdfp.MRACHiresUmapBuilder(varargin{:}));
                    this.builder_ = this.builder.prepareMprToAtlasT4;

                    pwd0 = pushd(this.sessionData.sessionPath);
                    umap = this.builder.buildUmap;
                    umap = umap.blurred(mlsiemens.MMRRegistry.instance().petPointSpread);
                    umap.save;
                    this.builder_ = this.builder.packageProduct(umap);
                    this.builder.teardownBuildUmaps;
                    popd(pwd0);
                case 'pseudoct'
                    this = TracerDirector2(mlfourdfp.PseudoCTBuilder(varargin{:}));
                    this.builder_ = this.builder.prepareMprToAtlasT4;

                    pwd0 = pushd(this.sessionData.sessionPath);
                    umap = this.builder.buildUmap;
                    umap = umap.blurred(mlsiemens.MMRRegistry.instance().petPointSpread);
                    umap.save;
                    this.builder_ = this.builder.packageProduct(umap);
                    this.builder.teardownBuildUmaps;
                    popd(pwd0);
                case 'ct'                    
                    this = TracerDirector2(mlfourdfp.CarneyUmapBuilder2(varargin{:}));
                    this.builder_ = this.builder.prepareMprToAtlasT4;

                    pwd0 = pushd(this.sessionData.sessionPath);
                    umap = this.builder.buildUmap;
                    umap.save;
                    this.builder_ = this.builder.packageProduct(umap);
                    this.builder.teardownBuildUmaps;
                    popd(pwd0);
                case 'nalgene_large'
                    this = TracerDirector2(mlan.DeepUmapBuilder(varargin{:}));

                    pwd0 = pushd(this.sessionData.sessionPath);
                    copyfile(fullfile(this.sessionData.projectPath, 'rawdata', 'CAL_PHANTOM2', 'umapSynth.nii.gz'))
                    popd(pwd0);
                otherwise
                    error('mlan:ValueError', 'TracerDirector2.constructUmaps')
            end            
            %this.populateTracerUmapFolder()
        end
    end
    
	methods
        function populateTracerUmapFolder(this)
            dcm = {};
            time = [];
            for g = globFoldersT(fullfile(this.sessionData.sessionPath, 'SCANS', '*/'))
                try
                    h = glob(fullfile(g{1}, 'DICOM', '*.dcm'));
                    info = dicominfo(string(h{1}));
                    if contains(info.SeriesDescription, 'UMAP')
                        dcm = [dcm; h{1}]; %#ok<AGROW> 
                        time_ = timeofday( ...
                            datetime( ...
                            [info.AcquisitionDate, info.AcquisitionTime], ...
                            'InputFormat', 'yyyyMMddHHmmss.SSSSSS'));
                        time = [time; time_]; %#ok<AGROW> 
                    end
                catch
                end
            end
            tbl = table(dcm, time);
            [~,idx] = min(abs(tbl.time - timeofday(this.sessionData)));
            dest = fullfile(this.sessionData.scanPath, 'umap');
            ensuredir(dest);
            copyfile(tbl.dcm{idx}, dest);
        end
        function step0(this)
            try
                if ~isfile(this.sessionData.umapSynthOpT1001)
                    if strcmp(this.sessionData.tracer, 'FDG')
                        umapType = 'nalgene_large';
                    else
                        umapType = 'deep';
                    end
                    this.constructUmaps('sessionData', this.sessionData, 'umapType', umapType)
                end
                this.populateTracerUmapFolder()
            catch ME
                handwarning(ME);
            end
        end
        function step_dynamic(this)
            try
                reg = mlan.Ccir993Registry.instance();
                image = 'jjleewustledu/niftypetr-image:reconstruction20191210';
                cmd = sprintf( ...
                    'nvidia-docker run -it --rm -v %s/hardwareumaps/:/hardwareumaps -v %s/:/ProjectsDir %s -p /ProjectsDir/CCIR_00993/derivatives/nipet/%s/%s', ...
                    getenv('DOCKER_HOME'), reg.projectsDir, image, this.sessionData.sessionFolder, this.sessionData.scanFolder);
                mlbash(cmd);
            catch ME
                handwarning(ME);
            end
        end
        function step_static(this)
            try
                reg = mlan.Ccir993Registry.instance();
                image = 'jjleewustledu/niftypetr-image:reconstruction20191210';
                cmd = sprintf( ...
                    'nvidia-docker run -it --rm -v %s/hardwareumaps/:/hardwareumaps -v %s/:/ProjectsDir %s -p /ProjectsDir/CCIR_00993/derivatives/nipet/%s/%s -m createStatic', ...
                    getenv('DOCKER_HOME'), reg.projectsDir, image, this.sessionData.sessionFolder, this.sessionData.scanFolder);
                mlbash(cmd);
            catch ME
                handwarning(ME);
            end
        end
        function step_phantom(this)
            try
                reg = mlan.Ccir993Registry.instance();
                image = 'jjleewustledu/niftypetr-image:reconstruction20191210';
                cmd = sprintf( ...
                    'nvidia-docker run -it --rm -v %s/hardwareumaps/:/hardwareumaps -v %s/:/ProjectsDir %s -p /ProjectsDir/CCIR_00993/derivatives/nipet/%s/%s -m createPhantom', ...
                    getenv('DOCKER_HOME'), reg.projectsDir, image, this.sessionData.sessionFolder, this.sessionData.scanFolder);
                mlbash(cmd);
            catch ME
                handwarning(ME);
            end
        end
        function step_resolve(this)
            try
                if ~this.sessionData.attenuationCorrected
                    this.instanceConstructResolvedNAC();
                else
                    this.instanceConstructResolvedAC();
                end
            catch ME
                handwarning(ME);
            end
        end

        function this = TracerDirector2(varargin)
 			%% TRACERDIRECTOR2
 			%  @param builder must be an mlpet.TracerBuilder.

 			this = this@mlnipet.CommonTracerDirector(varargin{:}); 
            this.prepareFreesurferData('sessionData', this.sessionData);
 		end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end
