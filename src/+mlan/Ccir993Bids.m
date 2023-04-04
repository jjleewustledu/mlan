classdef Ccir993Bids < handle & mlsiemens.BiographBids
	%% CCIR993BIDS  

	%  $Revision$
 	%  was created 13-Nov-2021 15:03:42 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
 	%% It was developed on Matlab 9.11.0.1769968 (R2021b) for MACI64.  Copyright 2021 John Joowon Lee.
 	
    properties
        flair_toglob
        pet_dyn_toglob
        pet_static_toglob
        t1w_toglob
        t2w_toglob
        tof_toglob
    end

    properties (Constant)
        BIDS_MODALITIES = {'anat' 'fmap' 'func' 'mri' 'pet'}
        DLICV_TAG = 'DLICV'
        PROJECT_FOLDER = 'CCIR_00993'
        SURFER_VERSION = '5.3-patch'
    end

    properties (Dependent)
        dixonumapPath	

        atlas_ic
        dlicv_ic
        T1_ic % FreeSurfer
        t1w_ic
        tof_ic
        tof_mask_ic
        wmparc_ic % FreeSurfer
    end

	methods % GET
        function g = get.dixonumapPath(this)
            g = fullfile(this.projectPath, 'staging', 'CCIR_00993_DL_DIXON_umap', '');
        end

        function g = get.atlas_ic(~)
            g = mlfourd.ImagingContext2( ...
                fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI_T1_1mm.nii.gz'));
        end
        function g = get.dlicv_ic(this)
            if ~isempty(this.dlicv_ic_)
                g = copy(this.dlicv_ic_);
                return
            end
            this.dlicv_ic_ = mlfourd.ImagingContext2( ...
                sprintf('%s_%s.nii.gz', this.t1w_ic.fqfileprefix, this.DLICV_TAG));
            if ~isfile(this.dlicv_ic_.fqfn)
                try
                    r = '';
                    [~,r] = this.build_dlicv(this.t1w_ic, this.dlicv_ic_);
                    assert(isfile(this.dlicv_ic_))
                catch ME
                    disp(r)
                    handexcept(ME)
                end
            end
            g = copy(this.dlicv_ic_);
        end
        function g = get.T1_ic(this)
            if ~isempty(this.T1_ic_)
                g = copy(this.T1_ic_);
                return
            end
            fn = fullfile(this.mriPath, 'T1.mgz');
            assert(isfile(fn))
            this.T1_ic_ = mlfourd.ImagingContext2(fn);
            this.T1_ic_.selectNiftiTool();
            this.T1_ic_.filepath = this.anatPath;
            this.T1_ic_.save();
            g = copy(this.T1_ic_);
        end
        function g = get.t1w_ic(this)
            if ~isempty(this.t1w_ic_)
                g = copy(this.t1w_ic_);
                return
            end
            globbed = globT(this.t1w_toglob);
            globbed = globbed(~contains(globbed, this.DLICV_TAG));
            fn = globbed{end};
            fn = fullfile(this.anatPath, strcat(mybasename(fn), '_orient-std.nii.gz'));
            if ~isfile(fn)
                this.build_orientstd(this.t1w_toglob);
            end
            this.t1w_ic_ = mlfourd.ImagingContext2(fn);
            g = copy(this.t1w_ic_);
        end
        function g = get.tof_ic(this)
            if ~isempty(this.tof_ic_)
                g = copy(this.tof_ic_);
                return
            end
            g = globT(fullfile(this.anatPath, '*TOF*.nii.gz'));
            assert(~isempty(g))
            fn = g{end};
            assert(isfile(fn))
            this.tof_ic_ = mlfourd.ImagingContext2(fn);
            this.tof_ic_.selectNiftiTool();
            this.tof_ic_.filepath = this.anatPath;
            this.tof_ic_.fileprefix = 'tof';
            this.tof_ic_.save();
            g = copy(this.tof_ic_);
        end
        function g = get.tof_mask_ic(this)
            if ~isempty(this.tof_mask_ic_)
                g = copy(this.tof_mask_ic_);
                return
            end
            tmp_ = this.tof_ic.blurred(6);
            tmp_ = tmp_.thresh(30);
            tmp_ = tmp_.binarized();
            this.tof_mask_ic_ = tmp_;
            g = copy(this.tof_mask_ic_);
        end
        function g = get.wmparc_ic(this)
            if ~isempty(this.wmparc_ic_)
                g = copy(this.wmparc_ic_);
                return
            end
            fn = fullfile(this.mriPath, 'wmparc.mgz');
            assert(isfile(fn))
            this.wmparc_ic_ = mlfourd.ImagingContext2(fn);
            this.wmparc_ic_.selectNiftiTool();
            this.wmparc_ic_.filepath = this.anatPath;
            this.wmparc_ic_.save();
            g = copy(this.wmparc_ic_);
        end
    end

    methods
 		function this = Ccir993Bids(varargin)
            %  @param destinationPath will receive outputs.  Must specify project ID & subject ID.
            %  @projectPath belongs to a CCIR project.
            %  @subjectFolder is the BIDS-adherent string for subject identity.

            this = this@mlsiemens.BiographBids(varargin{:})
            if isempty(this.subjectFolder_)
                this.parseDestinationPath(this.destinationPath_)
            end

            this.pet_dyn_toglob = fullfile(this.sourcePetPath, 'sub-*_trc-*_proc-dyn*_pet.nii.gz');
            this.pet_static_toglob = fullfile(this.sourcePetPath, 'sub-*_trc-*_proc-static*_pet.nii.gz');
            this.t1w_toglob = fullfile(this.sourceAnatPath, 'sub-*MPRAGE_T1_SAGITTAL*.nii.gz');

            this.json_ = mlan.Ccir993Json();        
        end
        function j = json(this)
            j = this.json_;
        end
        function r = registry(~)
            r = mlan.Ccir993Registry.instance();
        end
    end 

	methods (Static)
        function create_bids_folders()
            this = mlan.Ccir993Bids();
            ensuredir(this.projectPath)
            ensuredir(this.sourcedataPath)
            ensuredir(this.derivativesPath)

            for subf = asrow(this.json.subjectFolders)
                sourceSubPath = fullfile(this.sourcedataPath, subf{1});
                ensuredir(sourceSubPath)
                derivSubPath = fullfile(this.derivativesPath, subf{1});
                ensuredir(derivSubPath)
            end
        end
        function create_deepumap_folders()
            reg = mlan.Ccir993Registry.instance();
            pwd0 = pushd(fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00993', 'staging', 'CCIR_00993_DL_DIXON_umap', ''));

            for fold = globFoldersT('0993*')
                re = regexp(fold{1}, '(?<simpleid>0993_\d+)_\w+', 'names');
                subid = reg.x0993_to_sub(strcat('x', re.simpleid));
                sesid = reg.sub2ses(subid);
                dcms = glob(fullfile(fold{1}, 'umap', '*.dcm'));
                info = dicominfo(dcms{1});
                dt = strtok(strcat(info.AcquisitionDate, info.AcquisitionTime), '.');
                mlan.Ccir993Bids.dcm2niix(fold{1}, ...
                    'f', sprintf('%s_%s-%s_dumap', subid, sesid, dt), ...
                    'o', fullfile(reg.sessionsDir, sesid, ''));
            end

            popd(pwd0);
        end
        function create_tracer_folders(rawdata_dir)
            assert(isfolder(rawdata_dir));
            
            pwd0 = pushd(rawdata_dir);
            for g = glob('*.dcm')'
                info = dicominfo(g{1});
                d = mlan.Ccir993Bids.tracer_folder_from_dicominfo(info, 'Listmode');
                if ~isempty(d)
                    ensuredir(d);
                    movefile(info.Filename, d);
                    bf = strrep(info.Filename, '.dcm', '.bf');
                    movefile(bf, d);
                end
            end
            for g = glob('*.dcm')'
                info = dicominfo(g{1});
                d = mlan.Ccir993Bids.tracer_folder_from_dicominfo(info, 'Normalization');
                if ~isempty(d)
                    d = mlan.Ccir993Bids.ensure_norm_dir(d, info);
                    movefile(info.Filename, d);
                    bf = strrep(info.Filename, '.dcm', '.bf');
                    movefile(bf, d);
                end
            end
            popd(pwd0);
        end
        function d = ensure_norm_dir(d, info)
            if ~isfolder(fullfile(fileparts(d), 'LM'))
                % adjust SeriesTime coded in d
                d_ = strrep(d, info.SeriesTime, [info.SeriesTime(1:4), '*']); % replace seconds
                g = glob(d_);
                if ~isempty(g)
                    d = g{1};
                    ensuredir(d);
                end
            end
            ensuredir(d);
        end
        function tf = isdynamic(obj)
            tf = ~isstatic(obj);
        end
        function tf = isnac(obj)
            ic = mlfourd.ImagingContext2(obj);
            re = regexp(ic.filepath, '\w+(dt|DT)\d{14}(?<tags>\S*)', 'names');
            tf = contains(re.tags, 'nac', 'IgnoreCase', true);
        end
        function tf = isstatic(obj)
            ic = mlfourd.ImagingContext2(obj);
            re = regexp(ic.fileprefix, '\w+(dt|DT)\d{14}(?<tags>\S*)', 'names');
            tf = contains(re.tags, '_avgt') || contains(re.tags, '_sumt');
        end
        function tr = obj2tracer(obj)
            ic = mlfourd.ImagingContext2(obj);
            try
                re = regexp(ic.fileprefix, '(?<tr>\w+)(dt|DT)\d{14}\S*', 'names');
                tr = upper(re.tr);
            catch
                re = regexp(ic.fileprefix, '(?<tr>[a-z]+)r\d{1}\S*', 'names');
                tr = upper(re.tr);
            end
        end
        function c = tracer_code_from_dicominfo(info)
            assert(isstruct(info));

            txt = fileread(info.Filename);
            idx = strfind(txt, 'Radiopharmaceutical:');
            re = regexp(txt(idx:idx+100), 'Radiopharmaceutical:(?<trc>(\S+|\S+ \S+))\s*RadiopharmaceuticalStartTime:\S*', 'names');
            switch re.trc
                case 'Carbon monoxide'
                    c = 'OC';
                case 'Oxygen'
                    c = 'OO';
                case 'Oxygen-water'
                    c = 'HO';
                case 'Fluorodeoxyglucose'
                    c = 'FDG';
                otherwise
                    error('mlan:ValueError', ...
                        'Ccir993Bids.tracer_code_from_dicominfo does not recognize Radiopharmaceutical:%s', re.trc);
            end
        end
        function d = tracer_folder_from_dicominfo(info, type)
            assert(isstruct(info));

            if contains(info.ImageComments, 'Listmode') && strcmpi(type, 'Listmode')
                trc = mlan.Ccir993Bids.tracer_code_from_dicominfo(info);
                ses_d = fileparts(fileparts(info.Filename));
                trc_f = sprintf('%s_DT%s%s-Converted-NAC', trc, info.AcquisitionDate, info.AcquisitionTime);
                d = fullfile(ses_d, trc_f, 'LM', '');
                return
            end
            if contains(info.ImageComments, 'Normalization') && strcmpi(type, 'Normalization')
                trc = mlan.Ccir993Bids.tracer_code_from_dicominfo(info);
                ses_d = fileparts(fileparts(info.Filename));
                trc_f = sprintf('%s_DT%s%s-Converted-NAC', trc, info.AcquisitionDate, info.SeriesTime);
                d = fullfile(ses_d, trc_f, 'norm', '');
                return
            end
            d = '';
        end        
    end

    %% PROTECTED

    properties (Access = protected)
        json_
    end

    methods (Access = protected)
        function parseDestinationPath(this, dpath)
            if contains(dpath, 'sub-')
                ss = strsplit(dpath, filesep);
                this.subjectFolder_ = ss{contains(ss, 'sub-')}; % picks first occurance
            end
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end

