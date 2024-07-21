# tfsplit demo

// setup

rm -rf /tmp/work /tmp/tfsplit-demo
mkdir /tmp/work
cp -a modules 01-initial/* /tmp/work

pushd /tmp/work/all-the-things
tofu init
tofu apply -auto-approve

(cd /tmp/tfsplit-demo; find . -type f -print) | sort

./resources/east/thing-one
./resources/east/thing-two
./resources/west/thing-one
./resources/west/thing-two
./state/all-the-things/terraform.tfstate

tofu state pull >| a.tfstate
tfsplit --action split --state a.tfstate --dir z

popd

// refactor

cp -a 02-refactored/* /tmp/work

pushd /tmp/work/things
for i in one two; do
    cd $i
    mkdir z
    mv ../../all-the-things/z/module.thing-$i-* z
    cd z
    mv module.thing-$i-east 'module.thing["east"]'
    mv module.thing-$i-west 'module.thing["west"]'
    cd ..
    tfsplit --action merge --dir z --state a.tfstate
    tofu init
    tofu state push a.tfstate
    tofu plan
    cd ..
done

find ../all-the-things/z -type f -print

.tfsplit

(cd /tmp/tfsplit-demo; find . -type f -print) | sort

./resources/east/thing-one
./resources/east/thing-two
./resources/west/thing-one
./resources/west/thing-two
./state/all-the-things/terraform.tfstate
./state/things/one/terraform.tfstate
./state/things/two/terraform.tfstate
