
MYDIR=$HOME/software/grass-addons/utils/grass-gis-addons-overview-generator

docker run -it -v $MYDIR:/src --rm osgeo/grass-gis:releasebranch_8_3-debian bash
