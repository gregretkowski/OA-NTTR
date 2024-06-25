Welcome to the OA NTTR Fun Map!
Range template from 476th vFG

To get the mission download from the "[Releases](https://github.com/VFA-192-GOLDEN-DRAGONS/OA-NTTR/releases)" tab. this will give you
the latest version.

See the [In-Mission Briefing](briefing.md) for more specifics about the mission. 

The [Briefing Slide-Deck](https://docs.google.com/presentation/d/1_3V9OukroGKVx1U4lp2VjX9xQ4PAinb6OBZkA3OrtIE/edit#slide=id.p)
contains more details on the mission.

## Development Workflow

If you are going to make changes to the mission please '@K-Rad' on discord with a message
"I am going to make changes to NTTR, starting (now/date) and I'll have the changes to you
by date.". No need to wait for a response. Everyone is welcome to make changes to the mission,
the message is just to ensure two people arent making changes at the same time as DCS will
overwrite one person's changes with another person's if two people make changes concurrently.

#### Simplified workflow

If you dont have experience with github or working python, the best thing is to download the
latest release from
(the releases tab)[https://github.com/VFA-192-GOLDEN-DRAGONS/OA-NTTR/releases]
make your edits, and then send K-Rad a direct-message with the mizfile with your changes. I'll
then check them into the repo for you.

If you do have github/python follow the next set of instructions...

#### Workflow if comfortable with python/github

To work on this mission you will need DCS, git, and a python enterpreter. The mission is stored
in git as individual files -- not so much for diff'ability but because otherwise each
commit increases the overall git repo size by the size of the miz file.

To develop on this, you'll run `miztool.py` which will create a `miz` file in your DCS
Missions directory:

    python miztool.py --pack

Make all your edits via the DCS Mission Editor - once you are ready, sync the changes back into the repo, commit and push.

    python miztool.py --unpack
    git add OA-NTTR
    git commit -m "My awesome changes"
    git push origin my-topic-branch

A github action will make a miz file release any time something is merged to main, or to prerel;
make a PR and merge the branch to create the release.


## TODO

* ~~fix spawnable (ACTIVE_) SAM's in 7X ranges~~
* ~~fix up F18 radios using radio script~~
* Add more F16 air-starts (there are already SEAD air starts?)
* ~~figure out why bombing/target-scoring is broken~~
* ~~fix SEAD hot-starts to have SEAD loadouts~~
* remove 'activeranges' script??
* ~~tanker tacans Y>X docs/map~~
* ~~update my 'git remote' to the OA one~~
* ~~waypoints shown in the briefing are wrong vs the jet~~
* ~~Unhide all blue range targets so scoring works.. but hide red units.~~
* ~~adjust 'hide' 55/64 as jtacs for 65 are in 64.~~
* get NTTR template into DCS-MDC
* ~~make it so that _variants_ will load the right .miz file name on server reset~~


#### May be re-do items if I start again with old menu
* ~~hide all the ranges again~~
* ~~Add DSSM script~~
* ~~update WX to 'Nothing' / base 984, thick 656~~
* ~~update (f18) radios to not start on ATIS~~

