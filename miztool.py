#!/usr/bin/env python3
import argparse
from glob import glob
import os
import shutil
import yaml

from slpp import slpp as lua

# 'config/__init__.py' contains the config for this tool.
from config import config
mizname = config['mizname']
miz_subdir = config['miz_subdir']

def find_dcs_directory():
    home = os.environ['USERPROFILE']
    saved_games = os.path.join(home, 'Saved Games')
    dcs_openbeta = os.path.join(saved_games, 'DCS.openbeta')
    dcs = os.path.join(saved_games, 'DCS')
    candidate_dcs_dirs = [dcs_openbeta, dcs]
    for candidate_dcs_path in candidate_dcs_dirs:
        if os.path.exists(candidate_dcs_path):
            return candidate_dcs_path
    raise ValueError("Cannot find DCS saved games directory")

def get_dcs_missions_dir():
    dcs_dir = find_dcs_directory()
    missions_dir = os.path.join(dcs_dir, 'Missions')
    return missions_dir

def deep_merge(dict1, dict2):
    # Deep merge two dictionaries
    result = dict1.copy()
    for key, value in dict2.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):            
            result[key] = deep_merge(result[key], value)
        else:
            #self.logger.debug("merge repleace key %s value %s with %s" % (key, result[key], value))
            result[key] = value
    return result
    
def canonical_path(p):
    return os.path.normpath(os.path.abspath(p))

def main():
    parser = argparse.ArgumentParser(
        description='Pack/unpack DCS mission from/to the git repo.')

    command_group = parser.add_mutually_exclusive_group(required=True)
    command_group.add_argument(
        '--pack',
        action='store_true',
        help='Pack the miz contents in the git repo and copy to DCS saved games dir')
    command_group.add_argument(
        '--unpack',
        action='store_true',
        help='Extract the contents of the miz file from the DCS saved ' +
        'games dir to the local git repo.')
    command_group.add_argument(
        '--setbriefing',
        action='store_true',
        help='Updates dictionary to set the briefing')
    command_group.add_argument(
        '--makevariants',
        action='store_true',
        help='Creates wx variants of the mission')
    parser.add_argument(
        '-v',
        '--version',
        nargs='?',
        #const=os.getcwd(),
        default="DEV",
        help="Sets the version string")
    
    parser.add_argument(
        '-m',
        '--variant',
        nargs='?',
        #const=os.getcwd(),
        default="all",
        help="selects which variant to create")
    parser.add_argument(
        '-d',
        '--directory',
        nargs='?',
        const=os.getcwd(),
        help="If specified, copy the mission file into this directory.")

    parser.add_argument(
        '-f',
        '--force',
        action='store_true',
        default=False,
        help='Overwrite uncommitted changes when unpacking the mission')
    args = parser.parse_args()

    miz_fullname = mizname + '.miz'
    miz_fullpath = canonical_path(miz_fullname)

    use_default_dir = args.directory is None
    missions_dir = get_dcs_missions_dir(
    ) if use_default_dir else args.directory
    missions_dir = canonical_path(missions_dir)
    if not os.path.exists(missions_dir):
        os.makedirs(missions_dir)
    if not os.path.isdir(missions_dir):
        raise ValueError(f"{missions_dir} is not a directory")
    miz_in_missions_dir = canonical_path(
        os.path.join(missions_dir, miz_fullname))
    miz_local = os.path.join(os.getcwd(), miz_fullname)

    def pack():
        shutil.make_archive(mizname, format='zip', root_dir=miz_subdir)
        shutil.move(mizname + '.zip', miz_fullpath)
        if os.path.exists(miz_in_missions_dir):
            shutil.copyfile(dst=miz_in_missions_dir + '.backup',
                            src=miz_in_missions_dir)
        if miz_in_missions_dir != miz_fullpath:
            shutil.copyfile(dst=miz_in_missions_dir, src=miz_fullpath)
            os.remove(miz_local)


    def unpack():
        try:
            import git
        except ImportError:
            print("Cannot import git, there will be no warning for uncommitted changes. - try 'pip install python-git'")
            pass
        else:
            repo = git.Repo(os.getcwd())
            if not args.force and repo.is_dirty():
                print(
                    "Found untracked local changes, please commit or discard" +
                    " before unpacking mission.")
                exit(-1)

        print(f"Unpacking {miz_in_missions_dir} to {miz_fullname}")
        if miz_in_missions_dir != miz_fullname:
            shutil.copyfile(src=miz_in_missions_dir, dst=miz_fullname)
            shutil.unpack_archive(miz_fullname, miz_subdir, format='zip')
            os.remove(miz_local)


    def setbriefing(version=None,miz_local_subdir=None):
            if miz_local_subdir is None:
                miz_local_subdir = miz_subdir
            if version is None:
                version = args.version
            #print(glob(f"{miz_local_subdir}/l10n/DEFAULT/dictionary", recursive=True))
            with open('briefing.md', 'r') as file:
                briefing_str = file.read()
                briefing = briefing_str.replace('|PRERELEASE|', version).replace("\n","\\\n")
            for filename in glob(f"{miz_local_subdir}/l10n/DEFAULT/dictionary", recursive=True):
                with open(filename, 'r') as file:
                    filedata = file.read()
                    dictionary = lua.decode("{" + filedata + "}")
                    for dict_key in dictionary['dictionary'].keys():
                        if dict_key.startswith("DictKey_descriptionText"):
                            dictionary['dictionary'][dict_key] = briefing
                with open(filename, 'w') as file:
                    dictionary_string = f"dictionary = " + lua.encode(dictionary['dictionary'])
                    file.write(dictionary_string)


    def makevariants():
        # read yaml file variants
        with open('config/variants.yml') as f:
            config = yaml.safe_load(f)

        for key,val in config.items():
            if args.variant != "all" and args.variant != key:
                continue
            print(f"Processing variant {key}")
            variant_subdir = miz_subdir + "_" + key
            variant_mizname = mizname  + "_" + key

            # DESTRUCTIVE
            shutil.copytree(miz_subdir, variant_subdir, dirs_exist_ok=True)
            with open(variant_subdir+'/mission','r',encoding='UTF8') as mizfile:
                    mission_string = mizfile.read()
            mission = lua.decode("{" + mission_string + "}")
            mission['mission'] = deep_merge(mission['mission'],val)
            with open(variant_subdir+'/mission','w',encoding='UTF8') as mizfile:
                mission_string = "mission = " + lua.encode(mission['mission'])
                mizfile.write(mission_string)

            version_string = f"{args.version}:{key}"
            setbriefing(version=version_string,miz_local_subdir=variant_subdir)

            # replace mission file name - so server resets work.
            with open(variant_subdir+'/mission','r',encoding='UTF8') as mizfile:
                mission_string = mizfile.read().replace(mizname+".miz",variant_mizname+".miz")
            with open(variant_subdir+'/mission','w',encoding='UTF8') as mizfile:
                mizfile.write(mission_string)

            variant_mizfile = missions_dir + "/" + variant_mizname + ".miz"
            shutil.make_archive(variant_mizfile, format='zip', root_dir=variant_subdir)
            if os.path.exists(variant_mizfile):
                os.remove(variant_mizfile)
            shutil.move(variant_mizfile+'.zip', variant_mizfile)



    if args.pack:
        pack()
    elif args.unpack:
        unpack()
    #elif args.setversion:
    #    setversion()
    elif args.setbriefing:
        setbriefing()
    elif args.makevariants:
        makevariants()
    else:
        assert (False)


if __name__ == '__main__':
    main()
