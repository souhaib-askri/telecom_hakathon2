import os
from PIL import Image
import numpy as np
from scipy import ndimage

src_path = "/home/askri/.gemini/antigravity/brain/6fac1a0f-51c2-418c-a3c2-3136a9332964/.user_uploaded/media_1795327652882_cfca03ed.jpg"
im = Image.open(src_path).convert("RGBA")

out_dir = "assets/sprites/environment/outpost_tiles"
props_dir = "assets/sprites/props"
os.makedirs(out_dir, exist_ok=True)
os.makedirs(props_dir, exist_ok=True)

def extract_sprite(bbox, padding_clean=True):
    crop = im.crop(bbox).convert("RGBA")
    arr = np.array(crop)
    
    if not padding_clean:
        return Image.fromarray(arr)
        
    diff = np.sqrt(np.sum((arr[:, :, :3].astype(float) - np.array([48, 51, 56]))**2, axis=2))
    diff_grid = np.sqrt(np.sum((arr[:, :, :3].astype(float) - np.array([60, 65, 70]))**2, axis=2))
    is_bg_candidate = (diff < 19.0) | (diff_grid < 16.0)
    
    padded = np.pad(is_bg_candidate, ((1, 1), (1, 1)), mode='constant', constant_values=True)
    labeled, num = ndimage.label(padded)
    bg_label = labeled[0, 0]
    is_external_bg = (labeled[1:-1, 1:-1] == bg_label)
    
    arr[is_external_bg, 3] = 0
    return Image.fromarray(arr)

# 1. Base Ground Tiles (Mud & Dirt) - 80x80 each
# Row 0:
t_dirt_0 = im.crop((8, 6, 86, 84))
t_dirt_1 = im.crop((92, 6, 170, 84))
t_dirt_2 = im.crop((176, 6, 254, 84)) # with leaves

# Row 1:
t_dirt_3 = im.crop((8, 90, 86, 168))
t_dirt_4 = im.crop((92, 90, 170, 168))
t_dirt_5 = im.crop((176, 90, 254, 168))

# Row 2:
t_dirt_6 = im.crop((8, 174, 86, 252))
t_dirt_7 = im.crop((92, 174, 170, 252))

t_dirt_0.save(f"{out_dir}/tile_dirt_plain1.png")
t_dirt_1.save(f"{out_dir}/tile_dirt_plain2.png")
t_dirt_2.save(f"{out_dir}/tile_dirt_leaves.png")
t_dirt_3.save(f"{out_dir}/tile_dirt_loam1.png")
t_dirt_4.save(f"{out_dir}/tile_dirt_stones.png")
t_dirt_5.save(f"{out_dir}/tile_dirt_ridge.png")
t_dirt_6.save(f"{out_dir}/tile_dirt_grass.png")
t_dirt_7.save(f"{out_dir}/tile_dirt_corner.png")

# 2. Road Elements
# 4-way intersection (center of road cross)
# Center of cross is around (265, 260) with arms extending left, right, up, down
road_cross = im.crop((170, 170, 360, 350))
road_straight_h = im.crop((8, 258, 88, 338))
road_straight_h2 = im.crop((432, 258, 512, 338))
road_straight_v = im.crop((270, 5, 350, 170))
road_curve = im.crop((270, 430, 352, 565))

road_cross.save(f"{out_dir}/road_crossroad.png")
road_straight_h.save(f"{out_dir}/road_straight_h.png")
road_straight_h2.save(f"{out_dir}/road_straight_h2.png")
road_straight_v.save(f"{out_dir}/road_straight_v.png")
road_curve.save(f"{out_dir}/road_curve.png")

# 3. Props with Clean Transparency
tower_mount_plate = extract_sprite((668, 60, 842, 178)) # Steel bolted plate with collar
tower_mount_pole = extract_sprite((845, 0, 1014, 172))  # Base with pole
fence_barbed_wire = extract_sprite((555, 180, 938, 305))
fence_broken = extract_sprite((935, 195, 1015, 300))
wall_brick = extract_sprite((572, 310, 882, 415))
wall_brick_ruin = extract_sprite((885, 310, 1015, 415))
sandbags = extract_sprite((574, 420, 878, 473))
barrier_metal = extract_sprite((886, 418, 1008, 485))

boulder_moss = extract_sprite((578, 485, 665, 568))
barrels_oil = extract_sprite((680, 485, 765, 568))
crates_wood = extract_sprite((765, 490, 895, 568))
scrap_girders = extract_sprite((890, 495, 1008, 568))

tree_autumn = extract_sprite((382, 70, 460, 176))
bush_autumn = extract_sprite((384, 15, 456, 68))
reeds_tall = extract_sprite((448, 75, 510, 176))
dead_bush = extract_sprite((508, 80, 602, 176))
dead_tree = extract_sprite((600, 75, 650, 176))
grass_small = extract_sprite((460, 20, 505, 65))

# Save to environment and props
tower_mount_plate.save(f"{out_dir}/prop_tower_mount_plate.png")
tower_mount_pole.save(f"{out_dir}/prop_tower_mount_pole.png")
fence_barbed_wire.save(f"{out_dir}/prop_fence_barbed_wire.png")
fence_broken.save(f"{out_dir}/prop_fence_broken.png")
wall_brick.save(f"{out_dir}/prop_wall_brick.png")
wall_brick_ruin.save(f"{out_dir}/prop_wall_brick_ruin.png")
sandbags.save(f"{out_dir}/prop_sandbags.png")
barrier_metal.save(f"{out_dir}/prop_barrier_metal.png")

boulder_moss.save(f"{out_dir}/prop_boulder_moss.png")
barrels_oil.save(f"{out_dir}/prop_barrels_oil.png")
crates_wood.save(f"{out_dir}/prop_crates_wood.png")
scrap_girders.save(f"{out_dir}/prop_scrap_girders.png")

tree_autumn.save(f"{out_dir}/prop_tree_autumn.png")
bush_autumn.save(f"{out_dir}/prop_bush_autumn.png")
reeds_tall.save(f"{out_dir}/prop_reeds_tall.png")
dead_bush.save(f"{out_dir}/prop_dead_bush.png")
dead_tree.save(f"{out_dir}/prop_dead_tree.png")
grass_small.save(f"{out_dir}/prop_grass_small.png")

# Also copy key props directly to assets/sprites/props/
sandbags.save(f"{props_dir}/sandbags_barrier.png")
wall_brick.save(f"{props_dir}/brick_wall.png")
barrels_oil.save(f"{props_dir}/oil_drums.png")
crates_wood.save(f"{props_dir}/supply_crates.png")
scrap_girders.save(f"{props_dir}/scrap_girders.png")
tower_mount_plate.save(f"{props_dir}/tower_mount_plate.png")

print("All tiles and props extracted successfully!")
