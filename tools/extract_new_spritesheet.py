import os
from PIL import Image
import numpy as np
from scipy import ndimage

src_path = "/home/askri/.gemini/antigravity/brain/6fac1a0f-51c2-418c-a3c2-3136a9332964/.user_uploaded/media_1795329917170_5a7f891a.jpg"
im = Image.open(src_path).convert("RGBA")

out_dir = "telecom_hakathon/assets/sprites/environment/outpost_tiles"
props_dir = "telecom_hakathon/assets/sprites/props"
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

# 1. Base Ground Tiles with Grass (80x80)
tiles = [
    ("tile_dirt_grass1.png", (7, 0, 86, 84)),
    ("tile_dirt_grass2.png", (93, 0, 172, 84)),
    ("tile_dirt_grass3.png", (178, 0, 257, 84)),
    ("tile_dirt_plain1.png", (7, 90, 86, 170)),
    ("tile_dirt_plain2.png", (93, 90, 172, 170)),
    ("tile_dirt_leaves.png", (178, 90, 257, 170)),
    ("tile_dirt_loam1.png", (7, 176, 86, 256)),
    ("tile_dirt_loam2.png", (93, 176, 172, 256)),
]
for fname, bbox in tiles:
    im.crop(bbox).save(f"{out_dir}/{fname}")

# 2. Roads
im.crop((170, 170, 360, 350)).save(f"{out_dir}/road_crossroad.png")
im.crop((8, 258, 88, 338)).save(f"{out_dir}/road_straight_h.png")
im.crop((432, 258, 512, 338)).save(f"{out_dir}/road_straight_h2.png")
im.crop((270, 5, 350, 170)).save(f"{out_dir}/road_straight_v.png")
im.crop((270, 430, 352, 565)).save(f"{out_dir}/road_curve.png")

# 3. New Vegetation & Grass Clumps!
fern = extract_sprite((515, 88, 608, 170))
fern.save(f"{out_dir}/prop_fern_autumn.png")

# Extract the individual grass tufts
tuft_1 = extract_sprite((388, 365, 455, 418))
tuft_2 = extract_sprite((450, 355, 510, 412))
tuft_3 = extract_sprite((440, 435, 508, 490))
tuft_4 = extract_sprite((380, 505, 452, 560))
tuft_5 = extract_sprite((458, 505, 502, 555))
tuft_small1 = extract_sprite((460, 15, 505, 65))
tuft_small2 = extract_sprite((510, 15, 560, 65))
tuft_small3 = extract_sprite((562, 15, 605, 65))

tuft_1.save(f"{out_dir}/prop_grass_tuft1.png")
tuft_2.save(f"{out_dir}/prop_grass_tuft2.png")
tuft_3.save(f"{out_dir}/prop_grass_tuft3.png")
tuft_4.save(f"{out_dir}/prop_grass_tuft4.png")
tuft_5.save(f"{out_dir}/prop_grass_tuft5.png")
tuft_small1.save(f"{out_dir}/prop_grass_small1.png")
tuft_small2.save(f"{out_dir}/prop_grass_small2.png")
tuft_small3.save(f"{out_dir}/prop_grass_small3.png")

# Also copy grass tufts to props directory
tuft_1.save(f"{props_dir}/grass_tuft1.png")
tuft_2.save(f"{props_dir}/grass_tuft2.png")
tuft_3.save(f"{props_dir}/grass_tuft3.png")

# Trees & Shrubs
tree_autumn = extract_sprite((382, 70, 460, 176))
bush_autumn = extract_sprite((384, 15, 456, 68))
reeds_tall = extract_sprite((448, 75, 510, 176))
dead_bush = extract_sprite((508, 80, 602, 176))
dead_tree = extract_sprite((600, 75, 650, 176))

tree_autumn.save(f"{out_dir}/prop_tree_autumn.png")
bush_autumn.save(f"{out_dir}/prop_bush_autumn.png")
reeds_tall.save(f"{out_dir}/prop_reeds_tall.png")
dead_bush.save(f"{out_dir}/prop_dead_bush.png")
dead_tree.save(f"{out_dir}/prop_dead_tree.png")

# 4. Structures & Overgrown Fortifications
tower_mount_plate = extract_sprite((668, 60, 842, 178))
tower_mount_pole = extract_sprite((845, 0, 1014, 172))
fence_barbed_wire = extract_sprite((540, 178, 930, 305))
fence_broken = extract_sprite((930, 195, 1015, 300))
wall_brick = extract_sprite((565, 308, 878, 415))
wall_brick_ruin = extract_sprite((882, 308, 1015, 415))
sandbags = extract_sprite((568, 420, 872, 473))
barrier_metal = extract_sprite((884, 418, 1008, 485))

boulder_moss = extract_sprite((572, 485, 665, 568))
barrels_oil = extract_sprite((675, 485, 762, 568))
crates_wood = extract_sprite((765, 488, 895, 568))
scrap_girders = extract_sprite((890, 495, 1008, 568))

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

# Update props directory
sandbags.save(f"{props_dir}/sandbags_barrier.png")
wall_brick.save(f"{props_dir}/brick_wall.png")
barrels_oil.save(f"{props_dir}/oil_drums.png")
crates_wood.save(f"{props_dir}/supply_crates.png")
scrap_girders.save(f"{props_dir}/scrap_girders.png")
tower_mount_plate.save(f"{props_dir}/tower_mount_plate.png")

print("All new sprites extracted successfully!")
