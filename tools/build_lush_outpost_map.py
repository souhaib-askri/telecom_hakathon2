import os
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

# Set random seed for consistent, beautiful layout
random.seed(1337)
np.random.seed(1337)

tiles_dir = "telecom_hakathon/assets/sprites/environment/outpost_tiles"
env_dir = "telecom_hakathon/assets/sprites/environment"

# Load tiles with high grass density
tile_g1 = Image.open(f"{tiles_dir}/tile_dirt_grass1.png").convert("RGBA")
tile_g2 = Image.open(f"{tiles_dir}/tile_dirt_grass2.png").convert("RGBA")
tile_g3 = Image.open(f"{tiles_dir}/tile_dirt_grass3.png").convert("RGBA")
tile_p1 = Image.open(f"{tiles_dir}/tile_dirt_plain1.png").convert("RGBA")
tile_p2 = Image.open(f"{tiles_dir}/tile_dirt_plain2.png").convert("RGBA")
tile_leaves = Image.open(f"{tiles_dir}/tile_dirt_leaves.png").convert("RGBA")
tile_loam1 = Image.open(f"{tiles_dir}/tile_dirt_loam1.png").convert("RGBA")
tile_loam2 = Image.open(f"{tiles_dir}/tile_dirt_loam2.png").convert("RGBA")

# Create a rich pure-grass tile synthesized from the grass blades on the tiles
def create_pure_grass_tile(base_tile):
    arr = np.array(base_tile).copy()
    # Boost green and warm grass pixels
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    is_grass = (g > 60) & (r > 60) & (b < 60)
    # create vibrant overgrown grass tint
    arr[is_grass, 1] = np.clip(g[is_grass] * 1.15 + 10, 0, 255)
    arr[is_grass, 0] = np.clip(r[is_grass] * 1.05 + 5, 0, 255)
    return Image.fromarray(arr)

tile_grass_dense1 = create_pure_grass_tile(tile_g1)
tile_grass_dense2 = create_pure_grass_tile(tile_g2)
tile_grass_dense3 = create_pure_grass_tile(tile_g3)

# Load road assets
road_cross = Image.open(f"{tiles_dir}/road_crossroad.png").convert("RGBA")
road_h = Image.open(f"{tiles_dir}/road_straight_h.png").convert("RGBA")
road_h2 = Image.open(f"{tiles_dir}/road_straight_h2.png").convert("RGBA")
road_v = Image.open(f"{tiles_dir}/road_straight_v.png").convert("RGBA")
road_curve = Image.open(f"{tiles_dir}/road_curve.png").convert("RGBA")

# Load grass tufts and vegetation
tuft_1 = Image.open(f"{tiles_dir}/prop_grass_tuft1.png").convert("RGBA")
tuft_2 = Image.open(f"{tiles_dir}/prop_grass_tuft2.png").convert("RGBA")
tuft_3 = Image.open(f"{tiles_dir}/prop_grass_tuft3.png").convert("RGBA")
tuft_4 = Image.open(f"{tiles_dir}/prop_grass_tuft4.png").convert("RGBA")
tuft_5 = Image.open(f"{tiles_dir}/prop_grass_tuft5.png").convert("RGBA")
tuft_s1 = Image.open(f"{tiles_dir}/prop_grass_small1.png").convert("RGBA")
tuft_s2 = Image.open(f"{tiles_dir}/prop_grass_small2.png").convert("RGBA")
tuft_s3 = Image.open(f"{tiles_dir}/prop_grass_small3.png").convert("RGBA")

fern = Image.open(f"{tiles_dir}/prop_fern_autumn.png").convert("RGBA")
prop_tree = Image.open(f"{tiles_dir}/prop_tree_autumn.png").convert("RGBA")
bush_autumn = Image.open(f"{tiles_dir}/prop_bush_autumn.png").convert("RGBA")
reeds_tall = Image.open(f"{tiles_dir}/prop_reeds_tall.png").convert("RGBA")
dead_bush = Image.open(f"{tiles_dir}/prop_dead_bush.png").convert("RGBA")
prop_dead_tree = Image.open(f"{tiles_dir}/prop_dead_tree.png").convert("RGBA")

# Load overgrown structures
prop_plate = Image.open(f"{tiles_dir}/prop_tower_mount_plate.png").convert("RGBA")
prop_pole = Image.open(f"{tiles_dir}/prop_tower_mount_pole.png").convert("RGBA")
prop_fence = Image.open(f"{tiles_dir}/prop_fence_barbed_wire.png").convert("RGBA")
prop_fence_broken = Image.open(f"{tiles_dir}/prop_fence_broken.png").convert("RGBA")
prop_wall_brick = Image.open(f"{tiles_dir}/prop_wall_brick.png").convert("RGBA")
prop_wall_ruin = Image.open(f"{tiles_dir}/prop_wall_brick_ruin.png").convert("RGBA")
prop_sandbags = Image.open(f"{tiles_dir}/prop_sandbags.png").convert("RGBA")
prop_barrier = Image.open(f"{tiles_dir}/prop_barrier_metal.png").convert("RGBA")

prop_boulder = Image.open(f"{tiles_dir}/prop_boulder_moss.png").convert("RGBA")
prop_barrels = Image.open(f"{tiles_dir}/prop_barrels_oil.png").convert("RGBA")
prop_crates = Image.open(f"{tiles_dir}/prop_crates_wood.png").convert("RGBA")
prop_scrap = Image.open(f"{tiles_dir}/prop_scrap_girders.png").convert("RGBA")

MAP_W = 2816
MAP_H = 1536
TILE_S = 78

def generate_lush_sector_map():
    print(f"Building Lush Grassy Arena Map {MAP_W}x{MAP_H}...")
    canvas = Image.new("RGBA", (MAP_W, MAP_H), (45, 42, 28, 255))
    
    # 1. Fill ground primarily with GRASS and overgrown vegetation!
    cols = (MAP_W // TILE_S) + 2
    rows = (MAP_H // TILE_S) + 2
    
    # Heavy grass distribution (over 70% grass tiles!)
    ground_pool = (
        [tile_grass_dense1] * 25 +
        [tile_grass_dense2] * 25 +
        [tile_grass_dense3] * 20 +
        [tile_g1] * 15 +
        [tile_g2] * 15 +
        [tile_g3] * 15 +
        [tile_leaves] * 10 +
        [tile_p1] * 6 +
        [tile_p2] * 6 +
        [tile_loam1] * 4
    )
    
    for r in range(rows):
        for c in range(cols):
            t = random.choice(ground_pool)
            if random.random() < 0.35:
                t = t.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            if random.random() < 0.20:
                t = t.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
            canvas.paste(t, (c * TILE_S, r * TILE_S))
            
    # Add a soft grassy overlay layer for lush overgrown meadows
    grass_blend = Image.new("RGBA", (MAP_W, MAP_H), (0, 0, 0, 0))
    draw_g = ImageDraw.Draw(grass_blend)
    for _ in range(600):
        gx = random.randint(0, MAP_W)
        gy = random.randint(0, MAP_H)
        gr = random.randint(25, 90)
        # lush meadow green tint
        col = (72, 85, 38, random.randint(25, 60)) if random.random() < 0.7 else (115, 105, 45, random.randint(20, 50))
        draw_g.ellipse([gx - gr, gy - gr, gx + gr, gy + gr], fill=col)
    grass_blend = grass_blend.filter(ImageFilter.GaussianBlur(16))
    canvas.alpha_composite(grass_blend)

    # 2. Road Network with Tire Tracks
    road_rw = road_h.width
    for rx in range(0, MAP_W, road_rw):
        r_tile = road_h if (rx // road_rw) % 2 == 0 else road_h2
        canvas.alpha_composite(r_tile, (rx, 830))
        
    for ry in range(0, 830, road_v.height):
        canvas.alpha_composite(road_v, (1368, ry))
        
    for ry in range(890, MAP_H, road_v.height):
        canvas.alpha_composite(road_v, (1368, ry))
        
    for ry in range(300, 830, road_v.height):
        canvas.alpha_composite(road_v, (1010, ry))

    # Crossroads
    canvas.alpha_composite(road_cross, (1310, 760))
    canvas.alpha_composite(road_cross, (950, 760))

    # Helper function to paste sprite
    def paste_prop(prop_img, center_x, center_y, scale=1.0, flip_h=False):
        sp = prop_img
        if flip_h:
            sp = sp.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        if scale != 1.0:
            nw = max(1, int(sp.width * scale))
            nh = max(1, int(sp.height * scale))
            sp = sp.resize((nw, nh), Image.Resampling.LANCZOS)
        px = int(center_x - sp.width // 2)
        py = int(center_y - sp.height // 2)
        canvas.alpha_composite(sp, (px, py))

    # 3. Dense Grass Tufts Along Roads & Paths (Overgrown grass invading roads!)
    all_grass_tufts = [tuft_1, tuft_2, tuft_3, tuft_4, tuft_5, tuft_s1, tuft_s2, tuft_s3, fern]
    
    # Road edges grass (hundreds of grass tufts along the shoulders!)
    for rx in range(20, MAP_W - 20, 32):
        # Top shoulder of horizontal road
        if random.random() < 0.85:
            tuft = random.choice(all_grass_tufts)
            paste_prop(tuft, rx + random.randint(-8, 8), 820 + random.randint(-6, 6), scale=random.uniform(0.7, 1.1))
        # Bottom shoulder of horizontal road
        if random.random() < 0.85:
            tuft = random.choice(all_grass_tufts)
            paste_prop(tuft, rx + random.randint(-8, 8), 915 + random.randint(-6, 6), scale=random.uniform(0.7, 1.1))

    # Along vertical road shoulders
    for ry in range(20, MAP_H - 20, 35):
        if abs(ry - 860) < 60: continue
        # Left and right shoulders of vertical road
        if random.random() < 0.85:
            paste_prop(random.choice(all_grass_tufts), 1350 + random.randint(-6, 6), ry, scale=random.uniform(0.7, 1.05))
        if random.random() < 0.85:
            paste_prop(random.choice(all_grass_tufts), 1450 + random.randint(-6, 6), ry, scale=random.uniform(0.7, 1.05))

    # 4. Outpost Structures (Tower Base, Sandbags, Brick Walls, Barriers)
    # Bolted steel foundation plate under Tower (1408, 860)
    paste_prop(prop_plate, 1408, 860, scale=1.35)
    
    # Sandbags with overgrown grass at base:
    paste_prop(prop_sandbags, 1260, 930, scale=0.85)
    paste_prop(prop_sandbags, 1556, 930, scale=0.85, flip_h=True)
    paste_prop(prop_barrier, 1408, 730, scale=1.1)

    # Brick walls with tall reeds/grass along base:
    paste_prop(prop_wall_brick, 1408, 630, scale=0.9)
    paste_prop(prop_wall_ruin, 1580, 630, scale=0.9)
    paste_prop(prop_wall_ruin, 1236, 630, scale=0.9, flip_h=True)

    # Flanking brick & sandbag outposts:
    for px, py in [(700, 600), (2116, 600), (700, 1120), (2116, 1120)]:
        paste_prop(prop_wall_brick, px, py, scale=0.85)
        paste_prop(prop_sandbags, px, py + 70, scale=0.85)

    # 5. Recycling Depot & Salvage Bay (1050, 860)
    paste_prop(prop_scrap, 930, 860, scale=1.1)
    paste_prop(prop_scrap, 1170, 870, scale=0.9, flip_h=True)
    paste_prop(prop_crates, 960, 950, scale=1.0)
    paste_prop(prop_crates, 1140, 950, scale=0.95, flip_h=True)
    paste_prop(prop_barrels, 980, 780, scale=1.0)
    paste_prop(prop_barrels, 1120, 780, scale=1.0, flip_h=True)
    paste_prop(prop_barrier, 1050, 990, scale=0.9)

    # 6. Barbed Wire Fences with climbing vines and overgrown grass
    for fx in [500, 860, 1950, 2310]:
        paste_prop(prop_fence, fx, 220, scale=0.9)
        paste_prop(prop_fence, fx, 1340, scale=0.9)
    paste_prop(prop_fence_broken, 1040, 220, scale=0.9)
    paste_prop(prop_fence_broken, 1780, 220, scale=0.9, flip_h=True)
    paste_prop(prop_fence_broken, 1040, 1340, scale=0.9)
    paste_prop(prop_fence_broken, 1780, 1340, scale=0.9, flip_h=True)

    # 7. Mossy Boulders surrounded by grass
    boulders = [
        (350, 420), (550, 380), (2250, 420), (2450, 380),
        (350, 1150), (580, 1220), (2250, 1150), (2480, 1220),
        (820, 820), (1980, 820), (1408, 1150), (1408, 480)
    ]
    for bx, by in boulders:
        paste_prop(prop_boulder, bx, by, scale=random.uniform(0.85, 1.15))
        # Place grass tufts hugging the boulder
        for _ in range(3):
            paste_prop(random.choice(all_grass_tufts), bx + random.randint(-35, 35), by + random.randint(10, 30), scale=random.uniform(0.7, 0.95))

    # 8. Trees, Ferns, and Dense Perimeter Woodlands
    tree_spots = [
        (180, 160), (320, 140), (220, 300), (380, 260), (120, 480),
        (180, 1380), (320, 1400), (220, 1220), (380, 1260), (120, 1040),
        (2636, 160), (2496, 140), (2596, 300), (2436, 260), (2696, 480),
        (2636, 1380), (2496, 1400), (2596, 1220), (2436, 1260), (2696, 1040),
        (650, 120), (1408, 100), (2166, 120),
        (650, 1440), (1408, 1460), (2166, 1440)
    ]
    tree_spots.sort(key=lambda p: p[1])
    for tx, ty in tree_spots:
        t_sp = prop_tree if random.random() < 0.65 else prop_dead_tree
        paste_prop(t_sp, tx, ty, scale=random.uniform(1.2, 1.5))
        # Surround trees with lush ferns and autumn bushes
        paste_prop(fern, tx - 25, ty + 25, scale=random.uniform(0.9, 1.2))
        paste_prop(reeds_tall, tx + 25, ty + 20, scale=random.uniform(0.85, 1.1))
        paste_prop(bush_autumn, tx, ty + 30, scale=random.uniform(0.8, 1.1))

    # 9. EXTRA LUSH GRASS MEADOWS (Hundreds of grass tufts in the fields!)
    print("Planting 450+ organic grass tufts and foliage across meadows...")
    for _ in range(480):
        gx = random.randint(40, MAP_W - 40)
        gy = random.randint(40, MAP_H - 40)
        # Avoid road centerlines
        if (abs(gy - 860) < 30) or (abs(gx - 1408) < 30 and gy < 860):
            continue
        g_tuft = random.choice(all_grass_tufts)
        sc = random.uniform(0.65, 1.15)
        fl = random.choice([True, False])
        paste_prop(g_tuft, gx, gy, scale=sc, flip_h=fl)

    # 10. Tall Reeds & Fern Clusters in Wilderness Pockets
    for _ in range(60):
        rx = random.choice([random.randint(60, 600), random.randint(2200, MAP_W - 60)])
        ry = random.choice([random.randint(60, 500), random.randint(1000, MAP_H - 60)])
        paste_prop(fern, rx, ry, scale=random.uniform(0.9, 1.25))
        paste_prop(reeds_tall, rx + random.randint(-15, 15), ry + random.randint(5, 20), scale=random.uniform(0.8, 1.1))

    return canvas

print("=== Generating Extra-Lush Outpost Arena Map ===")
lush_map_day = generate_lush_sector_map()

# Save Day Map
day_path = f"{env_dir}/map_t4395k.png"
lush_map_day.convert("RGB").save(day_path, quality=95)
print(f"Saved Lush Day Map: {day_path} ({MAP_W}x{MAP_H})")
lush_map_day.save(f"{env_dir}/metalslug_arena_day.png")

# Generate Night Combat Edition
def make_night_version(img):
    arr = np.array(img).astype(float)
    r = arr[:, :, 0]
    g = arr[:, :, 1]
    b = arr[:, :, 2]
    
    # Cool moonlit nocturnal palette: preserve grassy greens and autumn tones
    r_n = r * 0.40 + 10.0
    g_n = g * 0.58 + 22.0  # boost foliage greens under moonlight
    b_n = b * 0.88 + 35.0  # lunar blue ambient
    
    # Warm autumn / golden grass highlights
    is_warm = (r > b + 20)
    r_n[is_warm] = r[is_warm] * 0.60 + 12.0
    g_n[is_warm] = g[is_warm] * 0.60 + 12.0
    b_n[is_warm] = b[is_warm] * 0.72 + 22.0
    
    out_arr = np.clip(np.dstack([r_n, g_n, b_n, arr[:, :, 3]]), 0, 255).astype(np.uint8)
    return Image.fromarray(out_arr)

lush_map_night = make_night_version(lush_map_day)
night_path = f"{env_dir}/metalslug_arena_night.png"
lush_map_night.save(night_path)
print(f"Saved Lush Night Map: {night_path} ({MAP_W}x{MAP_H})")

print("All lush maps created successfully!")
