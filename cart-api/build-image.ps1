$image_name = "nurih/cart-api"
$image_version = "0.9.1.1"
docker build -t "$($image_name):latest" .

$image_id = (docker image ls -q $image_name)

docker tag $image_id "$($image_name):$($image_version)"

write-host "Built image $($image_name) tagged 'latest' and $($image_version)"