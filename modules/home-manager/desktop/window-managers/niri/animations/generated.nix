{
  # NOTE FOR FUTURE EDITORS:
  # Niri's Home Manager module does not accept `duration-ms` or `curve`
  # under `window-open`, `window-close`, `window-resize`, or `screenshot-ui-open`
  # in this generated preset map. If you add new presets with custom shaders,
  # keep those timing fields out of those blocks or run
  # `strip-unsupported-options.py` after regenerating this file.
  bloom = {
    workspace-switch = {
      spring = {
        damping-ratio = 0.9;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 0.9;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    window-open = {
      custom-shader = ''
          vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            float p0 = niri_clamped_progress;
            float p  = smoothstep(0.0, 1.0, p0);

            vec2 size   = size_geo.xy;
            vec2 center = size * 0.5;
            vec2 pos    = coords_geo.xy * size;

            float scale = mix(0.01, 1.0, p);

            vec2 scaled_pos = (pos - center) / scale + center;
            vec2 uv = scaled_pos / size;

            if (uv.x < 0.0 || uv.x > 1.0 ||
                uv.y < 0.0 || uv.y > 1.0) {
                return vec4(0.0, 0.0, 0.0, 0.0);
            }

            return texture2D(niri_tex, uv);
          }
'';
    };
    window-close = {
      custom-shader = ''
          vec4 close_color(vec3 coords_geo, vec3 size_geo) {
            float p0 = niri_clamped_progress;
            float p  = smoothstep(0.0, 1.0, p0);

            vec2 size   = size_geo.xy;
            vec2 center = size * 0.5;
            vec2 pos    = coords_geo.xy * size;

            float scale = mix(1.0, 0.01, p);

            vec2 scaled_pos = (pos - center) / scale + center;
            vec2 uv = scaled_pos / size;

            if (uv.x < 0.0 || uv.x > 1.0 ||
                uv.y < 0.0 || uv.y > 1.0) {
                return vec4(0.0, 0.0, 0.0, 0.0);
            }

            return texture2D(niri_tex, uv);
          }
'';
    };
  };
  blur = {
    window-open = {
      custom-shader = ''
vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            
if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
    coords_geo.y < 0.0 || coords_geo.y > 1.0) {
    return vec4(0.0);
}


const float PI = 3.14;
float p = sin(niri_clamped_progress * (PI/2.0) );
float radius = mix(0.05,0.0, p);
const float samples = 7.0;

vec4 outColor = vec4(0.0);

// Define a constant for 2 * PI (tau), which represents a full circle in radians.
const float tau = 6.28318530718;

// Number of directions for sampling around the circle.
const float directions = 11.0;

// Outer loop iterates over multiple directions evenly spaced around a circle.
for (float d = 0.0; d < tau; d += tau / directions) {
    // Inner loop samples along each direction, with decreasing intensity.
    for (float s = 0.0; s < 1.0; s += 1.0 / samples) {
        // Calculate the offset for this sample based on direction, radius, and step.
        // The (1.0 - s) term ensures more sampling occurs closer to the center.
        vec2 offset = vec2(cos(d), sin(d)) * radius * (1.0 - s) / coords_geo.xy;

        // Add the sampled color at the offset position to the accumulator.
        outColor += texture2D(niri_tex, coords_geo.st + offset);
    }
}

// Normalize the accumulated color by dividing by the total number of samples
// and directions to ensure the result is averaged.

return (outColor / samples / directions) * p;

        }
'';
    };
    window-close = {
      custom-shader = ''
vec4 close_color(vec3 coords_geo, vec3 size_geo) {

if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
    coords_geo.y < 0.0 || coords_geo.y > 1.0) {
    return vec4(0.0);
}

const float PI = 3.14;
float p = sin(niri_clamped_progress * (PI/2.0) );

float radius = mix(0.0,0.05, p);
const float samples = 7.0;

vec4 outColor = vec4(0.0);

// Define a constant for 2 * PI (tau), which represents a full circle in radians.
const float tau = 6.28318530718;

// Number of directions for sampling around the circle.
const float directions = 11.0;

// Outer loop iterates over multiple directions evenly spaced around a circle.
for (float d = 0.0; d < tau; d += tau / directions) {
    // Inner loop samples along each direction, with decreasing intensity.
    for (float s = 0.0; s < 1.0; s += 1.0 / samples) {
        // Calculate the offset for this sample based on direction, radius, and step.
        // The (1.0 - s) term ensures more sampling occurs closer to the center.
        vec2 offset = vec2(cos(d), sin(d)) * radius * (1.0 - s) / coords_geo.xy;

        // Add the sampled color at the offset position to the accumulator.
        outColor += texture2D(niri_tex, coords_geo.st + offset);
    }
}


// Normalize the accumulated color by dividing by the total number of samples
// and directions to ensure the result is averaged.

return (outColor / samples / directions) * (1.0 - p);

}
'';
    };
    window-resize = {
      custom-shader = ''

float easeInOutSine(float t) {
    return -0.5 * (cos(3.141592653589793 * t) - 1.0);
}

vec4 resize_color(vec3 coords_geo, vec3 size_geo) {

if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
    coords_geo.y < 0.0 || coords_geo.y > 1.0) {
    return vec4(0.0);
}

const float PI = 3.14;
float p = easeInOutSine ( sin(niri_clamped_progress * PI ));

float radius = mix(0.0,0.0025, p);
const float samples = 7.0;

vec4 outColor = vec4(0.0);

// Define a constant for 2 * PI (tau), which represents a full circle in radians.
const float tau = 6.28318530718;

// Number of directions for sampling around the circle.
const float directions = 11.0;

// Outer loop iterates over multiple directions evenly spaced around a circle.
for (float d = 0.0; d < tau; d += tau / directions) {
    // Inner loop samples along each direction, with decreasing intensity.
    for (float s = 0.0; s < 1.0; s += 1.0 / samples) {
        // Calculate the offset for this sample based on direction, radius, and step.
        // The (1.0 - s) term ensures more sampling occurs closer to the center.
        vec2 offset = vec2(cos(d), sin(d)) * radius * (1.0 - s) / coords_geo.xy;

        outColor += texture2D(niri_tex_next, coords_geo.st + offset );
    }
}

// Normalize the accumulated color by dividing by the total number of samples
// and directions to ensure the result is averaged.
outColor = outColor / samples / directions;
outColor.a = 1.0;
return outColor ;
}
'';
    };
  };
  dither-glitch = {
    window-open = {
      custom-shader = ''
            float hash(vec2 p) {
                return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
            }

            float noise(vec2 p) {
                vec2 i = floor(p);
                vec2 f = fract(p);

                float a = hash(i);
                float b = hash(i + vec2(1.0, 0.0));
                float c = hash(i + vec2(0.0, 1.0));
                float d = hash(i + vec2(1.0, 1.0));

                vec2 u = f * f * (3.0 - 2.0 * f);

                return mix(a, b, u.x) +
                       (c - a) * u.y * (1.0 - u.x) +
                       (d - b) * u.y * u.x;
            }

            vec4 sample_rgb_split(vec2 uv, float amt) {
                vec2 off = vec2(amt, 0.0);
                float r = texture2D(niri_tex, uv + off).r;
                float g = texture2D(niri_tex, uv).g;
                float b = texture2D(niri_tex, uv - off).b;
                float a = texture2D(niri_tex, uv).a;
                return vec4(r, g, b, a);
            }

            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
                    coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                    return vec4(0.0);
                }

                float p = niri_clamped_progress;
                vec2 uv = coords_geo.xy;

                vec3 coords_tex = niri_geo_to_tex * coords_geo;
                vec2 tex_uv = coords_tex.st;

                // Slight unstable horizontal glitch early in the animation
                float early = 1.0 - smoothstep(0.0, 0.35, p);
                float band = step(0.72, noise(vec2(floor(uv.y * 42.0), floor(p * 30.0))));
                float tear = (noise(vec2(floor(uv.y * 90.0), floor(p * 50.0))) - 0.5)
                           * 0.045 * early * band;

                tex_uv.x += tear;

                // Tiny RGB split that settles as the window appears
                float rgb_amt = 0.008 * early;
                vec4 color = sample_rgb_split(tex_uv, rgb_amt);

                // Ordered-ish dithering / noise threshold reveal
                float pix = floor(uv.x * 120.0) + floor(uv.y * 120.0) * 131.0;
                float dither = fract(sin(pix * 91.3458) * 47453.5453);

                // Mix in animated noise so it feels glitchy rather than clean ordered dithering
                float n = noise(uv * 16.0 + vec2(0.0, p * 18.0));
                float threshold = mix(dither, n, 0.45);

                // Reveal nonlinearly so it 'snaps in' more at the end
                float reveal = smoothstep(0.0, 1.0, pow(p, 1.35));
                float alpha_mask = step(threshold, reveal);

                // Soften the harsh on/off just a little
                float soft = smoothstep(reveal - 0.10, reveal + 0.02, threshold);
                float alpha = mix(alpha_mask, 1.0 - soft, 0.35);

                // Scanline shimmer early on
                float scan = sin(uv.y * 240.0 + p * 35.0) * 0.5 + 0.5;
                float scan_amt = 0.10 * early * scan;

                color.rgb += scan_amt;
                color.rgb *= 0.92 + 0.08 * smoothstep(0.0, 1.0, p);

                return vec4(color.rgb, color.a * alpha);
            }
'';
    };
    window-close = {
      custom-shader = ''
            float hash(vec2 p) {
                return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
            }

            float noise(vec2 p) {
                vec2 i = floor(p);
                vec2 f = fract(p);

                float a = hash(i);
                float b = hash(i + vec2(1.0, 0.0));
                float c = hash(i + vec2(0.0, 1.0));
                float d = hash(i + vec2(1.0, 1.0));

                vec2 u = f * f * (3.0 - 2.0 * f);

                return mix(a, b, u.x) +
                       (c - a) * u.y * (1.0 - u.x) +
                       (d - b) * u.y * u.x;
            }

            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
                    coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                    return vec4(0.0);
                }

                float p = niri_clamped_progress;
                vec2 uv = coords_geo.xy;

                vec3 coords_tex = niri_geo_to_tex * coords_geo;
                vec2 tex_uv = coords_tex.st;

                // Aggressive per-band horizontal tearing
                float line_id = floor(uv.y * 70.0);
                float band_noise = noise(vec2(line_id, floor(p * 24.0)));
                float band_mask = step(0.45, band_noise);

                float tear = (noise(vec2(line_id * 1.7, floor(p * 40.0))) - 0.5)
                           * 0.18 * band_mask;

                // Add finer secondary tearing
                float micro = (noise(vec2(floor(uv.y * 220.0), floor(p * 80.0))) - 0.5)
                            * 0.04;

                tex_uv.x += tear + micro;

                // Channel-separated glitch
                float ch = 0.012 + 0.028 * p;
                float r = texture2D(niri_tex, tex_uv + vec2(ch, 0.0)).r;
                float g = texture2D(niri_tex, tex_uv).g;
                float b = texture2D(niri_tex, tex_uv - vec2(ch, 0.0)).b;
                float a = texture2D(niri_tex, tex_uv).a;

                vec4 color = vec4(r, g, b, a);

                // Bright digital tearing streaks
                float streak = step(0.82, noise(vec2(line_id * 2.3, floor(p * 60.0))));
                color.rgb += streak * band_mask * 0.22;

                // Rapid fade with glitch hanging on for a moment
                float alpha = 1.0 - smoothstep(0.0, 1.0, p);
                alpha *= 1.0 - smoothstep(0.45, 1.0, p);

                // Break the window apart near the end
                float breakup = step(noise(uv * 24.0 + vec2(0.0, p * 30.0)), 1.0 - p * 1.15);
                alpha *= breakup;

                return vec4(color.rgb, color.a * alpha);
            }
'';
    };
  };
  energize_b_niri = {
    window-open = {
      custom-shader = ''
            const vec3 EFFECT_COLOR = vec3(0.35, 0.85, 1.00);

            const float SHOWER_TIME  = 0.30;
            const float SHOWER_WIDTH = 0.30;
            const float STREAK_TIME  = 0.60;
            const float EDGE_FADE_PX = 50.0;

            float easeOutQuad(float t) {
                return -t * (t - 2.0);
            }

            float hash12(vec2 p) {
                vec3 p3 = fract(vec3(p.xyx) * 0.1031);
                p3 += dot(p3, p3.yzx + 33.33);
                return fract((p3.x + p3.y) * p3.z);
            }

            vec2 hash22(vec2 p) {
                vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
                p3 += dot(p3, p3.yzx + 33.33);
                return fract((p3.xx + p3.yz) * p3.zy);
            }

            float simplex2D(vec2 p) {
                const float K1 = 0.366025404;
                const float K2 = 0.211324865;

                vec2 i = floor(p + (p.x + p.y) * K1);
                vec2 a = p - i + (i.x + i.y) * K2;
                float m = step(a.y, a.x);
                vec2 o = vec2(m, 1.0 - m);
                vec2 b = a - o + K2;
                vec2 c = a - 1.0 + 2.0 * K2;

                vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
                vec3 n = h * h * h * h * vec3(
                    dot(a, -1.0 + 2.0 * hash22(i + 0.0)),
                    dot(b, -1.0 + 2.0 * hash22(i + o)),
                    dot(c, -1.0 + 2.0 * hash22(i + 1.0))
                );

                return 0.5 + 0.5 * dot(n, vec3(70.0));
            }

            float simplex2DFractal(vec2 p) {
                mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
                float f = 0.5000 * simplex2D(p);
                p = m * p;
                f += 0.2500 * simplex2D(p);
                p = m * p;
                f += 0.1250 * simplex2D(p);
                p = m * p;
                f += 0.0625 * simplex2D(p);
                return f;
            }

            float simplex3D(vec3 p) {
                const float F3 = 0.3333333;
                const float G3 = 0.1666667;

                vec3 s = floor(p + dot(p, vec3(F3)));
                vec3 x = p - s + dot(s, vec3(G3));

                vec3 e = step(vec3(0.0), x - x.yzx);
                vec3 i1 = e * (1.0 - e.zxy);
                vec3 i2 = 1.0 - e.zxy * (1.0 - e);

                vec3 x1 = x - i1 + G3;
                vec3 x2 = x - i2 + 2.0 * G3;
                vec3 x3 = x - 1.0 + 3.0 * G3;

                vec4 w;
                w.x = dot(x, x);
                w.y = dot(x1, x1);
                w.z = dot(x2, x2);
                w.w = dot(x3, x3);
                w = max(0.6 - w, 0.0);
                w *= w;
                w *= w;

                vec4 grad;
                grad.x = dot(-1.0 + 2.0 * vec3(hash12(s.xy), hash12(s.yz + 11.0), hash12(s.zx + 23.0)), x);
                grad.y = dot(-1.0 + 2.0 * vec3(hash12((s + i1).xy), hash12((s + i1).yz + 11.0), hash12((s + i1).zx + 23.0)), x1);
                grad.z = dot(-1.0 + 2.0 * vec3(hash12((s + i2).xy), hash12((s + i2).yz + 11.0), hash12((s + i2).zx + 23.0)), x2);
                grad.w = dot(-1.0 + 2.0 * vec3(hash12((s + 1.0).xy), hash12((s + 1.0).yz + 11.0), hash12((s + 1.0).zx + 23.0)), x3);

                return 0.5 + 0.5 * dot(w, grad) * 8.0;
            }

            float edgeMaskPx(vec2 px, vec2 sizePx, float fadePx) {
                float left   = smoothstep(0.0, fadePx, px.x);
                float top    = smoothstep(0.0, fadePx, px.y);
                float right  = smoothstep(0.0, fadePx, sizePx.x - px.x);
                float bottom = smoothstep(0.0, fadePx, sizePx.y - px.y);
                return left * top * right * bottom;
            }

            float relativeEdgeMask(vec2 uv, float fadeAmount) {
                float left   = smoothstep(0.0, fadeAmount, uv.x);
                float top    = smoothstep(0.0, fadeAmount, uv.y);
                float right  = smoothstep(0.0, fadeAmount, 1.0 - uv.x);
                float bottom = smoothstep(0.0, fadeAmount, 1.0 - uv.y);
                return left * top * right * bottom;
            }

            vec4 getMasks(float progress, vec2 uv, vec2 sizePx) {
                float showerProgress = progress / SHOWER_TIME;
                float streakProgress = clamp((progress - SHOWER_TIME) / STREAK_TIME, 0.0, 1.0);
                float fadeProgress   = clamp((progress - SHOWER_TIME) / (1.0 - SHOWER_TIME), 0.0, 1.0);

                float t = uv.y;

                float showerMask = smoothstep(
                    1.0, 0.0,
                    abs(showerProgress - t - SHOWER_WIDTH) / SHOWER_WIDTH
                );

                float streakMask = (showerProgress - t - SHOWER_WIDTH) > 0.0 ? 1.0 : 0.0;

                float atomMask = relativeEdgeMask(uv, 0.2);
                atomMask = max(0.0, atomMask - showerMask);
                atomMask *= streakMask;
                atomMask *= sqrt(max(0.0, 1.0 - fadeProgress * fadeProgress));

                showerMask += 0.05 * streakMask;
                streakMask = max(streakMask, showerMask);

                float edgeFade = edgeMaskPx(uv * sizePx, sizePx, EDGE_FADE_PX);
                showerMask *= edgeFade;
                streakMask *= edgeFade;

                float fade = smoothstep(0.0, 1.0, 1.0 + t - 2.0 * streakProgress);
                showerMask *= fade;
                streakMask *= fade;

                float windowMask = 1.0 - pow(1.0 - fadeProgress, 2.0);

                return vec4(showerMask, streakMask, atomMask, windowMask);
            }

            vec4 getInputColor(vec2 uv) {
                vec3 texCoord = niri_geo_to_tex * vec3(uv, 1.0);
                return texture2D(niri_tex, texCoord.xy);
            }

            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                vec2 uv = coords_geo.xy;

                if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                    return vec4(0.0);
                }

                float progress = easeOutQuad(niri_clamped_progress);

                vec4 masks  = getMasks(progress, uv, size_geo.xy);
                vec4 oColor = getInputColor(uv);

                // Dissolve window to effect color / transparency.
                oColor.rgb = mix(EFFECT_COLOR, oColor.rgb, 0.5 * masks.w + 0.5);
                oColor.a   = oColor.a * masks.w;

                // Add leading shower particles.
                vec2 showerUV = uv + vec2(0.0, -0.7 * progress / SHOWER_TIME);
                showerUV *= 0.02 * size_geo.xy;
                float shower = pow(simplex2D(showerUV), 10.0);
                oColor.rgb += EFFECT_COLOR * shower * masks.x;
                oColor.a   += shower * masks.x;

                // Add trailing streak lines.
                vec2 streakUV = uv + vec2(0.0, -progress / SHOWER_TIME);
                streakUV *= vec2(0.05 * size_geo.x, 0.001 * size_geo.y);
                float streaks = simplex2DFractal(streakUV) * 0.5;
                oColor.rgb += EFFECT_COLOR * streaks * masks.y;
                oColor.a   += streaks * masks.y;

                // Add glimmering atoms.
                vec2 atomUV = uv + vec2(0.0, -0.025 * progress / SHOWER_TIME);
                atomUV *= 0.2 * size_geo.xy;
                float atoms = pow(simplex3D(vec3(atomUV, niri_clamped_progress * 3.8 + niri_random_seed * 10.0)), 5.0);
                oColor.rgb += EFFECT_COLOR * atoms * masks.z;
                oColor.a   += atoms * masks.z;

                oColor.a = clamp(oColor.a, 0.0, 1.0);

                // niri expects premultiplied alpha.
                oColor.rgb *= oColor.a;

                return oColor;
            }
'';
    };
    window-close = {
      custom-shader = ''
            const vec3 EFFECT_COLOR = vec3(0.35, 0.85, 1.00);

            const float SHOWER_TIME  = 0.30;
            const float SHOWER_WIDTH = 0.30;
            const float STREAK_TIME  = 0.60;
            const float EDGE_FADE_PX = 50.0;

            float easeOutQuad(float t) {
                return -t * (t - 2.0);
            }

            float hash12(vec2 p) {
                vec3 p3 = fract(vec3(p.xyx) * 0.1031);
                p3 += dot(p3, p3.yzx + 33.33);
                return fract((p3.x + p3.y) * p3.z);
            }

            vec2 hash22(vec2 p) {
                vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
                p3 += dot(p3, p3.yzx + 33.33);
                return fract((p3.xx + p3.yz) * p3.zy);
            }

            float simplex2D(vec2 p) {
                const float K1 = 0.366025404;
                const float K2 = 0.211324865;

                vec2 i = floor(p + (p.x + p.y) * K1);
                vec2 a = p - i + (i.x + i.y) * K2;
                float m = step(a.y, a.x);
                vec2 o = vec2(m, 1.0 - m);
                vec2 b = a - o + K2;
                vec2 c = a - 1.0 + 2.0 * K2;

                vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
                vec3 n = h * h * h * h * vec3(
                    dot(a, -1.0 + 2.0 * hash22(i + 0.0)),
                    dot(b, -1.0 + 2.0 * hash22(i + o)),
                    dot(c, -1.0 + 2.0 * hash22(i + 1.0))
                );

                return 0.5 + 0.5 * dot(n, vec3(70.0));
            }

            float simplex2DFractal(vec2 p) {
                mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
                float f = 0.5000 * simplex2D(p);
                p = m * p;
                f += 0.2500 * simplex2D(p);
                p = m * p;
                f += 0.1250 * simplex2D(p);
                p = m * p;
                f += 0.0625 * simplex2D(p);
                return f;
            }

            float simplex3D(vec3 p) {
                const float F3 = 0.3333333;
                const float G3 = 0.1666667;

                vec3 s = floor(p + dot(p, vec3(F3)));
                vec3 x = p - s + dot(s, vec3(G3));

                vec3 e = step(vec3(0.0), x - x.yzx);
                vec3 i1 = e * (1.0 - e.zxy);
                vec3 i2 = 1.0 - e.zxy * (1.0 - e);

                vec3 x1 = x - i1 + G3;
                vec3 x2 = x - i2 + 2.0 * G3;
                vec3 x3 = x - 1.0 + 3.0 * G3;

                vec4 w;
                w.x = dot(x, x);
                w.y = dot(x1, x1);
                w.z = dot(x2, x2);
                w.w = dot(x3, x3);
                w = max(0.6 - w, 0.0);
                w *= w;
                w *= w;

                vec4 grad;
                grad.x = dot(-1.0 + 2.0 * vec3(hash12(s.xy), hash12(s.yz + 11.0), hash12(s.zx + 23.0)), x);
                grad.y = dot(-1.0 + 2.0 * vec3(hash12((s + i1).xy), hash12((s + i1).yz + 11.0), hash12((s + i1).zx + 23.0)), x1);
                grad.z = dot(-1.0 + 2.0 * vec3(hash12((s + i2).xy), hash12((s + i2).yz + 11.0), hash12((s + i2).zx + 23.0)), x2);
                grad.w = dot(-1.0 + 2.0 * vec3(hash12((s + 1.0).xy), hash12((s + 1.0).yz + 11.0), hash12((s + 1.0).zx + 23.0)), x3);

                return 0.5 + 0.5 * dot(w, grad) * 8.0;
            }

            float edgeMaskPx(vec2 px, vec2 sizePx, float fadePx) {
                float left   = smoothstep(0.0, fadePx, px.x);
                float top    = smoothstep(0.0, fadePx, px.y);
                float right  = smoothstep(0.0, fadePx, sizePx.x - px.x);
                float bottom = smoothstep(0.0, fadePx, sizePx.y - px.y);
                return left * top * right * bottom;
            }

            float relativeEdgeMask(vec2 uv, float fadeAmount) {
                float left   = smoothstep(0.0, fadeAmount, uv.x);
                float top    = smoothstep(0.0, fadeAmount, uv.y);
                float right  = smoothstep(0.0, fadeAmount, 1.0 - uv.x);
                float bottom = smoothstep(0.0, fadeAmount, 1.0 - uv.y);
                return left * top * right * bottom;
            }

            vec4 getMasks(float progress, vec2 uv, vec2 sizePx) {
                float showerProgress = progress / SHOWER_TIME;
                float streakProgress = clamp((progress - SHOWER_TIME) / STREAK_TIME, 0.0, 1.0);
                float fadeProgress   = clamp((progress - SHOWER_TIME) / (1.0 - SHOWER_TIME), 0.0, 1.0);

                float t = uv.y;

                float showerMask = smoothstep(
                    1.0, 0.0,
                    abs(showerProgress - t - SHOWER_WIDTH) / SHOWER_WIDTH
                );

                float streakMask = (showerProgress - t - SHOWER_WIDTH) > 0.0 ? 1.0 : 0.0;

                float atomMask = relativeEdgeMask(uv, 0.2);
                atomMask = max(0.0, atomMask - showerMask);
                atomMask *= streakMask;
                atomMask *= sqrt(max(0.0, 1.0 - fadeProgress * fadeProgress));

                showerMask += 0.05 * streakMask;
                streakMask = max(streakMask, showerMask);

                float edgeFade = edgeMaskPx(uv * sizePx, sizePx, EDGE_FADE_PX);
                showerMask *= edgeFade;
                streakMask *= edgeFade;

                float fade = smoothstep(0.0, 1.0, 1.0 + t - 2.0 * streakProgress);
                showerMask *= fade;
                streakMask *= fade;

                float windowMask = pow(1.0 - fadeProgress, 2.0);

                return vec4(showerMask, streakMask, atomMask, windowMask);
            }

            vec4 getInputColor(vec2 uv) {
                vec3 texCoord = niri_geo_to_tex * vec3(uv, 1.0);
                return texture2D(niri_tex, texCoord.xy);
            }

            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                vec2 uv = coords_geo.xy;

                if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                    return vec4(0.0);
                }

                float progress = easeOutQuad(niri_clamped_progress);

                vec4 masks  = getMasks(progress, uv, size_geo.xy);
                vec4 oColor = getInputColor(uv);

                oColor.rgb = mix(EFFECT_COLOR, oColor.rgb, 0.5 * masks.w + 0.5);
                oColor.a   = oColor.a * masks.w;

                vec2 showerUV = uv + vec2(0.0, -0.7 * progress / SHOWER_TIME);
                showerUV *= 0.02 * size_geo.xy;
                float shower = pow(simplex2D(showerUV), 10.0);
                oColor.rgb += EFFECT_COLOR * shower * masks.x;
                oColor.a   += shower * masks.x;

                vec2 streakUV = uv + vec2(0.0, -progress / SHOWER_TIME);
                streakUV *= vec2(0.05 * size_geo.x, 0.001 * size_geo.y);
                float streaks = simplex2DFractal(streakUV) * 0.5;
                oColor.rgb += EFFECT_COLOR * streaks * masks.y;
                oColor.a   += streaks * masks.y;

                vec2 atomUV = uv + vec2(0.0, -0.025 * progress / SHOWER_TIME);
                atomUV *= 0.2 * size_geo.xy;
                float atoms = pow(simplex3D(vec3(atomUV, niri_clamped_progress * 3.8 + niri_random_seed * 10.0)), 5.0);
                oColor.rgb += EFFECT_COLOR * atoms * masks.z;
                oColor.a   += atoms * masks.z;

                oColor.a = clamp(oColor.a, 0.0, 1.0);
                oColor.rgb *= oColor.a;

                return oColor;
            }
'';
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    window-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    window-resize = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    workspace-switch = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 1000;
        epsilon = 0.0001;
      };
    };
  };
  fold-window = {
    workspace-switch = {
      spring = {
        damping-ratio = 0.80;
        stiffness = 523;
        epsilon = 0.0001;
      };
    };
    window-open = {
      custom-shader = ''
        vec4 door_rise(vec3 coords_geo, vec3 size_geo) {
            float progress = niri_clamped_progress;
            
            // Tilt from 90 degrees (flat) to 0 degrees (upright)
            float tilt = (1.0 - progress) * 1.57079632;
            
            // Pivot point at bottom edge
            vec2 coords = coords_geo.xy * size_geo.xy;
            coords.y = size_geo.y - coords.y;
            
            // Distance from pivot (bottom edge)
            float dist_from_pivot = coords.y;
            
            // Calculate 3D position
            // Negative z_offset so it goes away from viewer (backward)
            float z_offset = -dist_from_pivot * sin(tilt);
            float y_compressed = dist_from_pivot * cos(tilt);
            
            // Apply perspective based on depth
            float perspective = 600.0;
            float perspective_scale = perspective / (perspective + z_offset);
            
            // Scale everything by perspective
            coords.x = (coords.x - size_geo.x * 0.5) * perspective_scale + size_geo.x * 0.5;
            coords.y = y_compressed * perspective_scale;
            
            // Flip Y back to normal coordinates
            coords.y = size_geo.y - coords.y;
            
            coords_geo = vec3(coords / size_geo.xy, 1.0);
            
            vec3 coords_tex = niri_geo_to_tex * coords_geo;
            vec4 color = texture2D(niri_tex, coords_tex.st);
            
            // Brighten as it rises
            float brightness = 0.4 + 0.6 * progress;
            color.rgb *= brightness;
            
            return color * progress;
        }
        vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            return door_rise(coords_geo, size_geo);
        }
'';
    };
    window-close = {
      custom-shader = ''
    vec4 bob_and_slide(vec3 coords_geo, vec3 size_geo) {
        float progress = niri_clamped_progress;
        
        float y_offset = 0.0;
        
        // Bob phase (0.0 to 0.25) - goes up then back to 0
        if (progress < 0.25) {
            float t = progress / 0.25;
            // Parabola: goes up to peak at t=0.5, back down to 0 at t=1.0
            y_offset = -40.0 * (1.0 - 4.0 * (t - 0.5) * (t - 0.5));
        }
        // Slide phase (0.25 to 1.0) - slides down
        else {
            float slide_progress = (progress - 0.25) / 0.75;
            y_offset = -slide_progress * (size_geo.y + 100.0);
        }
        
        // Apply transformation
        vec2 coords = coords_geo.xy * size_geo.xy;
        coords.y = coords.y + y_offset;
        
        coords_geo = vec3(coords / size_geo.xy, 1.0);
        
        vec3 coords_tex = niri_geo_to_tex * coords_geo;
        vec4 color = texture2D(niri_tex, coords_tex.st);
        
        return color;
    }
    vec4 close_color(vec3 coords_geo, vec3 size_geo) {
        return bob_and_slide(coords_geo, size_geo);
    }
'';
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 0.65;
        stiffness = 423;
        epsilon = 0.0001;
      };
    };
    window-movement = {
      spring = {
        damping-ratio = 0.65;
        stiffness = 300;
        epsilon = 0.0001;
      };
    };
    window-resize = {
      custom-shader = ''
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
                vec3 coords_tex_next = niri_geo_to_tex_next * coords_curr_geo;
                vec4 color = texture2D(niri_tex_next, coords_tex_next.st);
                return color;
            }
'';
    };
    config-notification-open-close = {
      spring = {
        damping-ratio = 0.65;
        stiffness = 923;
        epsilon = 0.001;
      };
    };
    screenshot-ui-open = {
      duration-ms = 200;
    };
    overview-open-close = {
      spring = {
        damping-ratio = 0.85;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
  };
  glide = {
    slowdown = 1.5;
    window-open = {
      custom-shader = ''
            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                float p = niri_clamped_progress;

                // Slight up-to-down settle.
                float slide_px = (1.0 - p) * 60.0;
                float slide_geo = slide_px / max(size_geo.x, 1.0);

                // Very subtle scale-up into place.
                float scale = 0.985 + 0.015 * p;

                vec2 uv = coords_geo.xy;
                uv -= vec2(0.5, 0.5);
                uv /= scale;
                uv += vec2(0.5, 0.5);

                uv.y -= slide_geo;

                vec3 coords_tex = niri_geo_to_tex * vec3(uv, 1.0);
                vec4 color = texture2D(niri_tex, coords_tex.st);

                // Gentle fade-in.
                color *= p;

                return color;
            }
'';
    };
    window-close = {
      custom-shader = ''
            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                float p = niri_clamped_progress;
                float inv = 1.0 - p;

                // Slight downward departure.
                float slide_px = p * 40.0;
                float slide_geo = slide_px / max(size_geo.x, 1.0);

                // Tiny scale-down on exit.
                float scale = 1.0 - 0.012 * p;

                vec2 uv = coords_geo.xy;
                uv -= vec2(0.5, 0.5);
                uv /= scale;
                uv += vec2(0.5, 0.5);

                uv.y -= slide_geo;

                vec3 coords_tex = niri_geo_to_tex * vec3(uv, 1.0);
                vec4 color = texture2D(niri_tex, coords_tex.st);

                color *= inv;
                return color;
            }
'';
    };
    window-resize = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 720;
        epsilon = 0.0001;
      };
      custom-shader = ''
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
                // Show the next texture, but with a very mild softening
                // toward the edges during motion for a less harsh resize feel.
                vec3 coords_tex_next = niri_geo_to_tex_next * coords_curr_geo;
                vec4 color = texture2D(niri_tex_next, coords_tex_next.st);

                vec2 uv = coords_curr_geo.xy;
                float edge =
                    min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));

                float vignette = smoothstep(0.0, 0.06, edge);
                color.rgb *= mix(0.985, 1.0, vignette);

                return color;
            }
'';
    };
    workspace-switch = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 760;
        epsilon = 0.0001;
      };
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 640;
        epsilon = 0.0001;
      };
    };
    window-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 700;
        epsilon = 0.0001;
      };
    };
    config-notification-open-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 820;
        epsilon = 0.001;
      };
    };
    exit-confirmation-open-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 560;
        epsilon = 0.01;
      };
    };
    screenshot-ui-open = {
      duration-ms = 220;
    };
    overview-open-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 620;
        epsilon = 0.0001;
      };
    };
    recent-windows-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 680;
        epsilon = 0.001;
      };
    };
  };
  glitch_00 = {
    window-open = {
      custom-shader = ''
            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) return vec4(0.0);
                float progress = niri_clamped_progress;
                float glitch = 1.0 - progress;
                vec2 uv = coords_geo.xy;

                // RGB channel splitting - channels converge as window opens
                float split = glitch * 0.04;
                vec3 cr = niri_geo_to_tex * vec3(uv + vec2(split, 0.0), 1.0);
                vec3 cg = niri_geo_to_tex * vec3(uv, 1.0);
                vec3 cb = niri_geo_to_tex * vec3(uv - vec2(split, 0.0), 1.0);

                float r = texture2D(niri_tex, cr.st).r;
                float g = texture2D(niri_tex, cg.st).g;
                float b = texture2D(niri_tex, cb.st).b;
                float a = texture2D(niri_tex, cg.st).a;
                vec3 color = vec3(r, g, b);

                // CRT scanline effect
                float scanline = 1.0 - 0.08 + 0.08 * sin(uv.y * 400.0);

                return vec4(color * scanline, a * progress);
            }
'';
    };
    window-close = {
      custom-shader = ''
            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) return vec4(0.0);
                float progress = niri_clamped_progress;
                vec2 uv = coords_geo.xy;

                // RGB channel splitting - channels separate as window closes
                float split = progress * 0.04;
                vec3 cr = niri_geo_to_tex * vec3(uv + vec2(split, 0.0), 1.0);
                vec3 cg = niri_geo_to_tex * vec3(uv, 1.0);
                vec3 cb = niri_geo_to_tex * vec3(uv - vec2(split, 0.0), 1.0);

                float r = texture2D(niri_tex, cr.st).r;
                float g = texture2D(niri_tex, cg.st).g;
                float b = texture2D(niri_tex, cb.st).b;
                float a = texture2D(niri_tex, cg.st).a;
                vec3 color = vec3(r, g, b);

                // CRT scanline effect
                float scanline = 1.0 - 0.08 + 0.08 * sin(uv.y * 400.0);

                return vec4(color * scanline, a * (1.0 - progress));
            }
'';
    };
  };
  glitch_01 = {
    slowdown = 1.5;
    window-open = {
      custom-shader = ''
        float gh(float n) {
            return fract(sin(n) * 43758.5453);
        }

        vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            float p = niri_clamped_progress;
            vec2 uv = coords_geo.xy;

            float intensity = (1.0 - p) * (1.0 - p);

            float tick = floor(p * 60.0) + niri_random_seed * 1000.0;
            float r1 = gh(tick * 1.13);
            float r2 = gh(tick * 2.37);
            float r3 = gh(tick * 3.71);
            float r4 = gh(tick * 4.19);
            float r5 = gh(tick * 5.53);
            float r6 = gh(tick * 6.91);

            vec2 off_r = vec2(r1 - 0.5, r2 - 0.5) * intensity * 0.12;
            vec2 off_g = vec2(r3 - 0.5, r4 - 0.5) * intensity * 0.12;
            vec2 off_b = vec2(r5 - 0.5, r6 - 0.5) * intensity * 0.12;

            float slice = floor(uv.y * 20.0);
            float slice_offset = (gh(slice + tick) - 0.5) * intensity * 0.08;

            vec2 uv_r = uv + off_r + vec2(slice_offset * 0.7, 0.0);
            vec2 uv_g = uv + off_g + vec2(slice_offset * -0.5, 0.0);
            vec2 uv_b = uv + off_b + vec2(slice_offset * 0.3, 0.0);

            vec3 tc_r = niri_geo_to_tex * vec3(uv_r, 1.0);
            vec3 tc_g = niri_geo_to_tex * vec3(uv_g, 1.0);
            vec3 tc_b = niri_geo_to_tex * vec3(uv_b, 1.0);

            vec4 color;
            color.r = texture2D(niri_tex, tc_r.st).r;
            color.g = texture2D(niri_tex, tc_g.st).g;
            color.b = texture2D(niri_tex, tc_b.st).b;
            color.a = max(max(
                texture2D(niri_tex, tc_r.st).a,
                texture2D(niri_tex, tc_g.st).a),
                texture2D(niri_tex, tc_b.st).a);

            float big_glitch = step(0.85, gh(tick * 0.77));
            vec2 shift = vec2((gh(tick * 1.5) - 0.5) * 0.06 * big_glitch * intensity, 0.0);
            vec3 tc_shift = niri_geo_to_tex * vec3(uv + shift, 1.0);
            vec4 shifted = texture2D(niri_tex, tc_shift.st);
            color = mix(color, shifted, big_glitch * intensity * 0.4);

            float scanline = 1.0 - sin(uv.y * size_geo.y * 3.14159) * 0.06 * intensity;
            color.rgb *= scanline;

            float alpha = smoothstep(0.0, 0.15, p);
            return color * alpha;
        }
'';
    };
    window-close = {
      custom-shader = ''
        float gh(float n) {
            return fract(sin(n) * 43758.5453);
        }

        vec4 close_color(vec3 coords_geo, vec3 size_geo) {
            float p = niri_clamped_progress;
            vec2 uv = coords_geo.xy;

            float intensity = p * p;

            float tick = floor(p * 60.0) + niri_random_seed * 1000.0;
            float r1 = gh(tick * 1.13);
            float r2 = gh(tick * 2.37);
            float r3 = gh(tick * 3.71);
            float r4 = gh(tick * 4.19);
            float r5 = gh(tick * 5.53);
            float r6 = gh(tick * 6.91);

            vec2 off_r = vec2(r1 - 0.5, r2 - 0.5) * intensity * 0.15;
            vec2 off_g = vec2(r3 - 0.5, r4 - 0.5) * intensity * 0.15;
            vec2 off_b = vec2(r5 - 0.5, r6 - 0.5) * intensity * 0.15;

            float slice = floor(uv.y * 20.0);
            float slice_offset = (gh(slice + tick) - 0.5) * intensity * 0.12;

            vec2 uv_r = uv + off_r + vec2(slice_offset * 0.7, 0.0);
            vec2 uv_g = uv + off_g + vec2(slice_offset * -0.5, 0.0);
            vec2 uv_b = uv + off_b + vec2(slice_offset * 0.3, 0.0);

            vec3 tc_r = niri_geo_to_tex * vec3(uv_r, 1.0);
            vec3 tc_g = niri_geo_to_tex * vec3(uv_g, 1.0);
            vec3 tc_b = niri_geo_to_tex * vec3(uv_b, 1.0);

            vec4 color;
            color.r = texture2D(niri_tex, tc_r.st).r;
            color.g = texture2D(niri_tex, tc_g.st).g;
            color.b = texture2D(niri_tex, tc_b.st).b;
            color.a = max(max(
                texture2D(niri_tex, tc_r.st).a,
                texture2D(niri_tex, tc_g.st).a),
                texture2D(niri_tex, tc_b.st).a);

            float big_glitch = step(0.8 - p * 0.3, gh(tick * 0.77));
            vec2 shift = vec2((gh(tick * 1.5) - 0.5) * 0.08 * big_glitch * intensity, 0.0);
            vec3 tc_shift = niri_geo_to_tex * vec3(uv + shift, 1.0);
            vec4 shifted = texture2D(niri_tex, tc_shift.st);
            color = mix(color, shifted, big_glitch * intensity * 0.5);

            float scanline = 1.0 - sin(uv.y * size_geo.y * 3.14159) * 0.08 * intensity;
            color.rgb *= scanline;

            float alpha = smoothstep(1.0, 0.6, p);
            return color * alpha;
        }
'';
    };
    window-resize = {
      custom-shader = ''
        float gh(float n) {
            return fract(sin(n) * 43758.5453);
        }

        float hash(vec2 p) {
            return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
        }

        float noise(vec2 p) {
            vec2 i = floor(p);
            vec2 f = fract(p);

            float a = hash(i);
            float b = hash(i + vec2(1.0, 0.0));
            float c = hash(i + vec2(0.0, 1.0));
            float d = hash(i + vec2(1.0, 1.0));

            vec2 u = f * f * (3.0 - 2.0 * f);

            return mix(a, b, u.x) +
                    (c - a) * u.y * (1.0 - u.x) +
                    (d - b) * u.y * u.x;
        }
        
        vec4 resize_color(vec3 coords_geo, vec3 size_geo) {
            if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
                coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                return vec4(0.0);
            }

            float p = niri_clamped_progress;
            vec2 uv = coords_geo.xy;

            float intensity = (p * p) * 0.5;

            float niri_random_seed = 0.5 ;
            float tick = floor(p * 60.0) + niri_random_seed * 1000.0;
            float r1 = gh(tick * 1.13);
            float r2 = gh(tick * 2.37);
            float r3 = gh(tick * 3.71);
            float r4 = gh(tick * 4.19);
            float r5 = gh(tick * 5.53);
            float r6 = gh(tick * 6.91);

            vec2 off_r = vec2(r1 - 0.5, r2 - 0.5) * intensity * 0.15;
            vec2 off_g = vec2(r3 - 0.5, r4 - 0.5) * intensity * 0.15;
            vec2 off_b = vec2(r5 - 0.5, r6 - 0.5) * intensity * 0.15;

            float slice = floor(uv.y * 20.0);
            float slice_offset = (gh(slice + tick) - 0.5) * intensity * 0.08;

            vec4 color;
            color.r = texture2D(niri_tex_next, uv + off_r + vec2(slice_offset * 0.7, 0.0)).r;
            color.g = texture2D(niri_tex_next, uv + off_g + vec2(slice_offset * 0.7, 0.0)).g;
            color.b = texture2D(niri_tex_next, uv + off_b + vec2(slice_offset * 0.7, 0.0)).b;
            color.a = 1.0;

            float big_glitch = step(0.86, gh(tick * 0.77));
            vec2 shift = vec2((gh(tick * 1.5) - 0.5) * 0.06 * big_glitch * intensity, 0.0);
            vec3 tc_shift = size_geo * vec3(uv + shift, 1.0);
            vec4 shifted = texture2D(niri_tex_next, tc_shift.st);
            color = mix(color, shifted, intensity * 0.4 );

            float scanline = 1.0 - sin(uv.y * size_geo.y * 3.14159) * 0.06 * intensity;
            color.rgb *= scanline;

            return color ;
        }
'';
    };
  };
  incinerate = {
    slowdown = 3.0;
    workspace-switch = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 1000;
        epsilon = 0.0001;
      };
    };
    window-open = {
      custom-shader = ''
float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

vec3 fire_ramp(float t) {
    t = saturate(t);
    vec3 ember = vec3(0.00, 0.00, 0.00);
    vec3 flame = vec3(1.00, 0.35, 0.05);
    vec3 hot   = vec3(1.00, 0.95, 0.75);
    return mix(mix(ember, flame, saturate(t * 1.6)), hot, saturate((t - 0.45) * 1.8));
}

vec4 alpha_over(vec4 base, vec4 over) {
    return over + base * (1.0 - over.a);
}

vec4 burn_sample(vec3 coords_geo, vec3 size_geo, bool opening) {
    if (coords_geo.x < -1.2 || coords_geo.x > 2.2 || coords_geo.y < -1.2 || coords_geo.y > 2.2) {
        return vec4(0.0);
    }

    vec2 uv = coords_geo.xy;
    vec3 tex_coords = niri_geo_to_tex * coords_geo;
    vec4 tex = texture2D(niri_tex, tex_coords.st);

    float progress = niri_clamped_progress;
    float scale = 1.0;
    float turbulence = 0.22;
    vec2 start_pos = vec2(0.5, 0.95);
    vec2 seed = vec2(niri_random_seed, fract(niri_random_seed * 37.17));

    float scorch_width = 0.20 * scale;
    float burn_width   = 0.030 * scale;
    float smoke_width  = 0.90 * scale;
    float flame_width  = 0.20 * scale;

    float hide_threshold = mix(opening ? 0.0 : -scorch_width,
                               1.0 + smoke_width,
                               progress);

    vec2 scorch_range = opening
        ? vec2(hide_threshold - scorch_width, hide_threshold)
        : vec2(hide_threshold, hide_threshold + scorch_width);
    vec2 burn_range  = vec2(hide_threshold - burn_width, hide_threshold + burn_width);
    vec2 flame_range = vec2(hide_threshold - flame_width, hide_threshold);
    vec2 smoke_range = vec2(hide_threshold - smoke_width, hide_threshold);

    float aspect = max(size_geo.x, size_geo.y);
    float circle = length((uv - start_pos) * (size_geo.xy / aspect));

    vec2 p = uv * (size_geo.xy / 240.0) / scale;
    float smoke_noise = fbm(p * 2.2 + seed + vec2(0.0, progress * 1.8));
    float gradient = mix(circle, smoke_noise,
                         saturate(200.0 * turbulence * scale / max(size_geo.x, size_geo.y)));

    float smoke_mask = smoothstep(0.0, 1.0, (gradient - smoke_range.x) / smoke_width);
    float flame_mask = smoothstep(0.0, 1.0, (gradient - flame_range.x) / flame_width);
    float fire_mask = smoothstep(1.0, 0.0, abs(gradient - hide_threshold) / burn_width);
    float scorch_mask = smoothstep(1.0, 0.0, (gradient - scorch_range.x) / scorch_width);

    if (opening) {
        scorch_mask = 1.0 - scorch_mask;
    }

    vec4 color = vec4(0.0);
    bool show_tex = (!opening && gradient > hide_threshold) || (opening && gradient < hide_threshold);

    if (show_tex) {
        color = tex;
    }

    if (smoke_range.x < gradient && gradient < smoke_range.y) {
        float smoke = smoke_mask * smoke_noise * 0.55;
        color = alpha_over(color, vec4(vec3(smoke * 0.45), smoke));

        float ember_noise = fbm(p * 5.0 + seed * 3.0 - smoke_noise * vec2(0.0, 0.8));
        float embers = clamp(pow(max(ember_noise - 0.15, 0.0), 8.0) * 3.0, 0.0, 1.0) * smoke_mask;
        vec3 ember_rgb = fire_ramp(0.45 + embers * 0.55) * embers;
        color += vec4(ember_rgb, embers);
    }

    if (scorch_range.x < gradient && gradient < scorch_range.y) {
        vec3 scorch = mix(color.rgb, vec3(0.10, 0.05, 0.02) * color.a, 0.4);
        color.rgb = mix(color.rgb, scorch, scorch_mask);
    }

    if (min(burn_range.x, flame_range.x) < gradient && gradient < max(burn_range.y, flame_range.y)) {
        float flame_noise = fbm(p * 3.2 + seed * 5.0 + vec2(0.0, progress * 3.5));

        if (flame_range.x < gradient && gradient < flame_range.y) {
            float flame = clamp(pow(max(flame_noise - 0.05, 0.0), 5.5) * 2.4, 0.0, 1.0) * flame_mask;
            vec3 flame_rgb = fire_ramp(0.65 + flame * 0.35) * flame;
            color += vec4(flame_rgb, flame);
        }

        if (burn_range.x < gradient && gradient < burn_range.y) {
            float fire = fire_mask * pow(max(flame_noise, 0.0), 2.0) * max(color.a, 0.15);
            fire = clamp(fire, 0.0, 1.0);
            vec3 fire_rgb = fire_ramp(0.75 + fire * 0.25) * fire;
            color += vec4(fire_rgb, fire);
        }
    }

    return color;
}

vec4 open_color(vec3 coords_geo, vec3 size_geo) {
    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
        coords_geo.y < 0.0 || coords_geo.y > 1.0) {
        return vec4(0.0);
    }

    return burn_sample(coords_geo, size_geo, true);
}
'';
    };
    window-close = {
      custom-shader = ''
float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

vec3 fire_ramp(float t) {
    t = saturate(t);
    vec3 ember = vec3(0.00, 0.00, 0.00);
    vec3 flame = vec3(1.00, 0.35, 0.05);
    vec3 hot   = vec3(1.00, 0.95, 0.75);
    return mix(mix(ember, flame, saturate(t * 1.6)), hot, saturate((t - 0.45) * 1.8));
}

vec4 alpha_over(vec4 base, vec4 over) {
    return over + base * (1.0 - over.a);
}

vec4 burn_sample(vec3 coords_geo, vec3 size_geo, bool opening) {
    if (coords_geo.x < -1.2 || coords_geo.x > 2.2 || coords_geo.y < -1.2 || coords_geo.y > 2.2) {
        return vec4(0.0);
    }

    vec2 uv = coords_geo.xy;
    vec3 tex_coords = niri_geo_to_tex * coords_geo;
    vec4 tex = texture2D(niri_tex, tex_coords.st);

    float progress = niri_clamped_progress;
    float scale = 1.0;
    float turbulence = 0.22;
    vec2 start_pos = vec2(0.5, 0.95);
    vec2 seed = vec2(niri_random_seed, fract(niri_random_seed * 37.17));

    float scorch_width = 0.20 * scale;
    float burn_width   = 0.030 * scale;
    float smoke_width  = 0.90 * scale;
    float flame_width  = 0.20 * scale;

    float hide_threshold = mix(opening ? 0.0 : -scorch_width,
                               1.0 + smoke_width,
                               progress);

    vec2 scorch_range = opening
        ? vec2(hide_threshold - scorch_width, hide_threshold)
        : vec2(hide_threshold, hide_threshold + scorch_width);
    vec2 burn_range  = vec2(hide_threshold - burn_width, hide_threshold + burn_width);
    vec2 flame_range = vec2(hide_threshold - flame_width, hide_threshold);
    vec2 smoke_range = vec2(hide_threshold - smoke_width, hide_threshold);

    float aspect = max(size_geo.x, size_geo.y);
    float circle = length((uv - start_pos) * (size_geo.xy / aspect));

    vec2 p = uv * (size_geo.xy / 240.0) / scale;
    float smoke_noise = fbm(p * 2.2 + seed + vec2(0.0, progress * 1.8));
    float gradient = mix(circle, smoke_noise,
                         saturate(200.0 * turbulence * scale / max(size_geo.x, size_geo.y)));

    float smoke_mask = smoothstep(0.0, 1.0, (gradient - smoke_range.x) / smoke_width);
    float flame_mask = smoothstep(0.0, 1.0, (gradient - flame_range.x) / flame_width);
    float fire_mask = smoothstep(1.0, 0.0, abs(gradient - hide_threshold) / burn_width);
    float scorch_mask = smoothstep(1.0, 0.0, (gradient - scorch_range.x) / scorch_width);

    if (opening) {
        scorch_mask = 1.0 - scorch_mask;
    }

    vec4 color = vec4(0.0);
    bool show_tex = (!opening && gradient > hide_threshold) || (opening && gradient < hide_threshold);

    if (show_tex) {
        color = tex;
    }

    if (smoke_range.x < gradient && gradient < smoke_range.y) {
        float smoke = smoke_mask * smoke_noise * 0.55;
        color = alpha_over(color, vec4(vec3(smoke * 0.45), smoke));

        float ember_noise = fbm(p * 5.0 + seed * 3.0 - smoke_noise * vec2(0.0, 0.8));
        float embers = clamp(pow(max(ember_noise - 0.15, 0.0), 8.0) * 3.0, 0.0, 1.0) * smoke_mask;
        vec3 ember_rgb = fire_ramp(0.45 + embers * 0.55) * embers;
        color += vec4(ember_rgb, embers);
    }

    if (scorch_range.x < gradient && gradient < scorch_range.y) {
        vec3 scorch = mix(color.rgb, vec3(0.10, 0.05, 0.02) * color.a, 0.4);
        color.rgb = mix(color.rgb, scorch, scorch_mask);
    }

    if (min(burn_range.x, flame_range.x) < gradient && gradient < max(burn_range.y, flame_range.y)) {
        float flame_noise = fbm(p * 3.2 + seed * 5.0 + vec2(0.0, progress * 3.5));

        if (flame_range.x < gradient && gradient < flame_range.y) {
            float flame = clamp(pow(max(flame_noise - 0.05, 0.0), 5.5) * 2.4, 0.0, 1.0) * flame_mask;
            vec3 flame_rgb = fire_ramp(0.65 + flame * 0.35) * flame;
            color += vec4(flame_rgb, flame);
        }

        if (burn_range.x < gradient && gradient < burn_range.y) {
            float fire = fire_mask * pow(max(flame_noise, 0.0), 2.0) * max(color.a, 0.15);
            fire = clamp(fire, 0.0, 1.0);
            vec3 fire_rgb = fire_ramp(0.75 + fire * 0.25) * fire;
            color += vec4(fire_rgb, fire);
        }
    }

    return color;
}

vec4 close_color(vec3 coords_geo, vec3 size_geo) {
    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
        coords_geo.y < 0.0 || coords_geo.y > 1.0) {
        return vec4(0.0);
    }

    return burn_sample(coords_geo, size_geo, false);
}
'';
    };
    window-resize = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
      custom-shader = ''
vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
    vec3 coords_tex_next = niri_geo_to_tex_next * coords_curr_geo;
    vec4 color = texture2D(niri_tex_next, coords_tex_next.st);
    return color;
}
'';
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    window-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    config-notification-open-close = {
      spring = {
        damping-ratio = 0.6;
        stiffness = 1000;
        epsilon = 0.001;
      };
    };
    exit-confirmation-open-close = {
      spring = {
        damping-ratio = 0.6;
        stiffness = 500;
        epsilon = 0.01;
      };
    };
    screenshot-ui-open = {
      duration-ms = 200;
    };
    overview-open-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    recent-windows-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.001;
      };
    };
  };
  pixelate = {
    workspace-switch = {
      duration-ms = 300;
      curve = "ease-out-cubic";
    };
    window-open = {
      custom-shader = ''
      vec4 pixelate_open(vec3 coords_geo, vec3 size_geo) {
          // Discard pixels outside window bounds
          if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
              return vec4(0.0);
          }
          float progress = niri_clamped_progress;
          float border_width = 0.008; // Adjust based on your border size
          vec2 coords = coords_geo.xy;
          // Check if we're in the border region
          bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                          coords.y < border_width || coords.y > (1.0 - border_width);
          // Only pixelate the inner content, not the border
          if (!in_border) {
              float pixel_size = (1.0 - progress) * 0.1;
              if (pixel_size > 0.0) {
                  coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
              }
              // Clamp sampling to avoid border area
              coords = clamp(coords, border_width, 1.0 - border_width);
          }
          vec3 new_coords = vec3(coords, 1.0);
          vec3 coords_tex = niri_geo_to_tex * new_coords;
          vec4 color = texture2D(niri_tex, coords_tex.st);
          color.a *= progress;
          return color;
      }
      vec4 open_color(vec3 coords_geo, vec3 size_geo) {
        return pixelate_open(coords_geo, size_geo);
      }
'';
    };
    window-close = {
      custom-shader = ''
      vec4 pixelate_close(vec3 coords_geo, vec3 size_geo) {
          // Discard pixels outside window bounds
          if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
              return vec4(0.0);
          }
          float progress = niri_clamped_progress;
          float border_width = 0.008;
          vec2 coords = coords_geo.xy;
          // Check if we're in the border region
          bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                          coords.y < border_width || coords.y > (1.0 - border_width);
          // Only pixelate the inner content, not the border
          if (!in_border) {
              float pixel_size = progress * 0.1;
              if (pixel_size > 0.0) {
                  coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
              }
              // Clamp sampling to avoid border area
              coords = clamp(coords, border_width, 1.0 - border_width);
          }
          vec3 new_coords = vec3(coords, 1.0);
          vec3 coords_tex = niri_geo_to_tex * new_coords;
          vec4 color = texture2D(niri_tex, coords_tex.st);
          color.a *= (1.0 - progress);
          return color;
      }
      vec4 close_color(vec3 coords_geo, vec3 size_geo) {
        return pixelate_close(coords_geo, size_geo);
      }
'';
    };
  };
  pop-drop = {
    workspace-switch = {
      spring = {
        damping-ratio = 0.85;
        stiffness = 700;
        epsilon = 0.0001;
      };
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 0.85;
        stiffness = 700;
        epsilon = 0.0001;
      };
    };
    window-open = {
      custom-shader = ''
        vec4 zoom_in(vec3 coords_geo, vec3 size_geo) {
          float progress = niri_clamped_progress;
          float scale = progress;
          vec2 coords = (coords_geo.xy - vec2(0.5, 0.5)) * size_geo.xy;
          coords = coords / scale;
          coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 0.5), 1.0);
          vec3 coords_tex = niri_geo_to_tex * coords_geo;
          vec4 color = texture2D(niri_tex, coords_tex.st);
          color.a *= progress;

          return color;
        }
        vec4 open_color(vec3 coords_geo, vec3 size_geo) {
          return zoom_in(coords_geo, size_geo);
        }
'';
    };
    window-close = {
      custom-shader = ''
        vec4 fall_and_rotate(vec3 coords_geo, vec3 size_geo) {
          float progress = niri_clamped_progress * niri_clamped_progress;
          vec2 coords = (coords_geo.xy - vec2(0.5, 1.0)) * size_geo.xy;
          coords.y -= progress * 1440.0;
          float random = (niri_random_seed - 0.5) / 2.0;
          random = sign(random) - random;
          float max_angle = 0.5 * random;
          float angle = progress * max_angle;
          mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
          coords = rotate * coords;
          coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 1.0), 1.0);
          vec3 coords_tex = niri_geo_to_tex * coords_geo;
          vec4 color = texture2D(niri_tex, coords_tex.st);
          color.a *= (1.0 - progress);

          return color;
        }
        vec4 close_color(vec3 coords_geo, vec3 size_geo) {
          return fall_and_rotate(coords_geo, size_geo);
        }
'';
    };
  };
  prism_fold = {
    slowdown = 1.5;
    workspace-switch = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 1000;
        epsilon = 0.0001;
      };
    };
    window-open = {
      custom-shader = ''

// Exponential Easing
float easeInExpo(float t) {
    return t == 0.0 ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}
float easeOutExpo(float t) {
    return t == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
}
float easeInOutExpo(float t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    return t < 0.5 ? 0.5 * pow(2.0, 20.0 * t - 10.0) : 1.0 - 0.5 * pow(2.0, -20.0 * t + 10.0);
}
// Sine Easing
float easeInSine(float t) {
    return 1.0 - cos((t * 3.141592653589793) / 2.0);
}
float easeOutSine(float t) {
    return sin((t * 3.141592653589793) / 2.0);
}
float easeInOutSine(float t) {
    return -0.5 * (cos(3.141592653589793 * t) - 1.0);
}
// Quartic Easing
float easeInQuart(float t) {
    return t * t * t * t;
}
float easeOutQuart(float t) {
    float f = t - 1.0;
    return 1.0 - f * f * f * f;
}
float easeInOutQuart(float t) {
    return t < 0.5 ? 8.0 * t * t * t * t : 1.0 - 8.0 * (t - 1.0) * (t - 1.0) * (t - 1.0) * (t - 1.0);
}

// Cubic Easing
float easeInCubic(float t) {
    return t * t * t;
}

float easeOutCubic(float t) {
    float f = t - 1.0;
    return f * f * f + 1.0;
}

float easeInOutCubic(float t) {
    return t < 0.5
        ? 4.0 * t * t * t
        : 1.0 + 4.0 * (t - 1.0) * (t - 1.0) * (t - 1.0);
}

vec2 scaleUV(vec2 uv, vec2 pivot, vec2 scale) {
    return (uv - pivot) / scale + pivot;
}

vec4 open_color(vec3 coords_geo, vec3 size_geo) {
    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
        coords_geo.y < 0.0 || coords_geo.y > 1.0) {
        return vec4(0.0);
    }

    vec2 uv = coords_geo.xy;
    float p = niri_clamped_progress;

    float s = mix(0.82, 1.0, easeOutCubic(p));
    vec2 baseUV = scaleUV(uv, vec2(0.5, 0.5), vec2(s, s));

    float rOff = mix(-0.01, 0.0, easeOutExpo(p));
    float gOff = mix( 0.000, 0.0, easeInOutSine(p));
    float bOff = mix( 0.01, 0.0, easeInExpo(p));

    vec4 xyScale = vec4(0.0);
    xyScale.r = mix(0.0, 1.0, easeInQuart(p));
    xyScale.g = mix(0.0, 1.0, easeInExpo(p));
    xyScale.b = mix(0.0, 1.0, easeInSine(p));

    vec2 uvR = scaleUV(baseUV + vec2(rOff, 0.0), vec2(0.5, 0.5), vec2(xyScale.r));
    vec2 uvG = scaleUV(baseUV + vec2(gOff, 0.0), vec2(0.5, 0.5), vec2(xyScale.g));
    vec2 uvB = scaleUV(baseUV + vec2(bOff, 0.0), vec2(0.5, 0.5), vec2(xyScale.b));

    vec4 outColor = vec4(0.0);
    outColor.r = texture2D(niri_tex, uvR).r;
    outColor.g = texture2D(niri_tex, uvG).g;
    outColor.b = texture2D(niri_tex, uvB).b;

    float avgRGB = (outColor.r + outColor.g + outColor.b) / 3.0;
    outColor.a = smoothstep(0.0, 0.5, avgRGB);

    return outColor;
}
'';
    };
    window-close = {
      custom-shader = ''
// Exponential Easing
float easeInExpo(float t) {
    return t == 0.0 ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}
float easeOutExpo(float t) {
    return t == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
}
float easeInOutExpo(float t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    return t < 0.5 ? 0.5 * pow(2.0, 20.0 * t - 10.0) : 1.0 - 0.5 * pow(2.0, -20.0 * t + 10.0);
}
// Sine Easing
float easeInSine(float t) {
    return 1.0 - cos((t * 3.141592653589793) / 2.0);
}
float easeOutSine(float t) {
    return sin((t * 3.141592653589793) / 2.0);
}
float easeInOutSine(float t) {
    return -0.5 * (cos(3.141592653589793 * t) - 1.0);
}
// Quartic Easing
float easeInQuart(float t) {
    return t * t * t * t;
}
float easeOutQuart(float t) {
    float f = t - 1.0;
    return 1.0 - f * f * f * f;
}
float easeInOutQuart(float t) {
    return t < 0.5 ? 8.0 * t * t * t * t : 1.0 - 8.0 * (t - 1.0) * (t - 1.0) * (t - 1.0) * (t - 1.0);
}

// Cubic Easing
float easeInCubic(float t) {
    return t * t * t;
}

float easeOutCubic(float t) {
    float f = t - 1.0;
    return f * f * f + 1.0;
}

float easeInOutCubic(float t) {
    return t < 0.5
        ? 4.0 * t * t * t
        : 1.0 + 4.0 * (t - 1.0) * (t - 1.0) * (t - 1.0);
}

vec2 scaleUV(vec2 uv, vec2 pivot, vec2 scale) {
    return (uv - pivot) / scale + pivot;
}

vec4 close_color(vec3 coords_geo, vec3 size_geo) {

    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
        coords_geo.y < 0.0 || coords_geo.y > 1.0) {
        return vec4(0.0);
    }


    vec2 uv = coords_geo.xy;
    float p = 1.0 - niri_clamped_progress;

    float s = mix(0.82, 1.0, easeOutCubic(p));
    vec2 baseUV = scaleUV(uv, vec2(0.5, 0.5), vec2(s, s));

    float rOff = mix(-0.01, 0.0, easeOutExpo(p));
    float gOff = mix( 0.000, 0.0, easeInOutSine(p));
    float bOff = mix( 0.01, 0.0, easeInExpo(p));

    vec4 xyScale = vec4(0.0);
    xyScale.r = mix(0.0, 1.0, easeInQuart(p));
    xyScale.g = mix(0.0, 1.0, easeInExpo(p));
    xyScale.b = mix(0.0, 1.0, easeInSine(p));

    vec2 uvR = scaleUV(baseUV + vec2(rOff, 0.0), vec2(0.5, 0.5), vec2(xyScale.r));
    vec2 uvG = scaleUV(baseUV + vec2(gOff, 0.0), vec2(0.5, 0.5), vec2(xyScale.g));
    vec2 uvB = scaleUV(baseUV + vec2(bOff, 0.0), vec2(0.5, 0.5), vec2(xyScale.b));

    vec4 outColor = vec4(0.0);
    outColor.r = texture2D(niri_tex, uvR).r;
    outColor.g = texture2D(niri_tex, uvG).g;
    outColor.b = texture2D(niri_tex, uvB).b;

    float avgRGB = (outColor.r + outColor.g + outColor.b) / 3.0;
    outColor.a = smoothstep(0.0, 0.5, avgRGB);

    return outColor;
}
'';
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    window-movement = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    window-resize = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
      custom-shader = ''

// Exponential Easing
float easeInExpo(float t) {
    return t == 0.0 ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}
float easeOutExpo(float t) {
    return t == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
}
float easeInOutExpo(float t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    return t < 0.5 ? 0.5 * pow(2.0, 20.0 * t - 10.0) : 1.0 - 0.5 * pow(2.0, -20.0 * t + 10.0);
}
// Sine Easing
float easeInSine(float t) {
    return 1.0 - cos((t * 3.141592653589793) / 2.0);
}
float easeOutSine(float t) {
    return sin((t * 3.141592653589793) / 2.0);
}
float easeInOutSine(float t) {
    return -0.5 * (cos(3.141592653589793 * t) - 1.0);
}
// Quartic Easing
float easeInQuart(float t) {
    return t * t * t * t;
}
float easeOutQuart(float t) {
    float f = t - 1.0;
    return 1.0 - f * f * f * f;
}
float easeInOutQuart(float t) {
    return t < 0.5 ? 8.0 * t * t * t * t : 1.0 - 8.0 * (t - 1.0) * (t - 1.0) * (t - 1.0) * (t - 1.0);
}

vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {

    float p = niri_clamped_progress;
    vec3 coords_tex_next = niri_geo_to_tex_next * coords_curr_geo;

    float distance = 0.0075;

    vec4 outColor = vec4(0.0);

    vec2 rXY = mix(
        vec2(-distance),
        vec2(0.0),
        easeInQuart(p)
    );

    vec2 gXY = mix(
        vec2(0.0,0.0),
        vec2(0.0),
        easeInQuart(p)
    );

    vec2 bXY = mix(
        vec2(distance),
        vec2(0.0),
        easeInSine(p)
    );

    outColor.r = texture2D(niri_tex_next, coords_tex_next.st + rXY).r;
    outColor.g = texture2D(niri_tex_next, coords_tex_next.st + gXY).g;
    outColor.b = texture2D(niri_tex_next, coords_tex_next.st + bXY).b;
    outColor.a = texture2D(niri_tex_next, coords_tex_next.st ).a;

    return outColor;
}
'';
    };
    config-notification-open-close = {
      spring = {
        damping-ratio = 0.6;
        stiffness = 1000;
        epsilon = 0.001;
      };
    };
    exit-confirmation-open-close = {
      spring = {
        damping-ratio = 0.6;
        stiffness = 500;
        epsilon = 0.01;
      };
    };
    screenshot-ui-open = {
      duration-ms = 200;
    };
    overview-open-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
    recent-windows-close = {
      spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.001;
      };
    };
  };
  ribbons = {
    workspace-switch = {
      spring = {
        damping-ratio = 0.80;
        stiffness = 523;
        epsilon = 0.0001;
      };
    };
    window-open = {
      custom-shader = ''
    vec4 open_color(vec3 coords_geo, vec3 size_geo) {
        float progress = niri_clamped_progress;
        
        // Completely random angle (0 to 2*PI)
        float random_angle = niri_random_seed * 6.28318;
        
        // Rotate the coordinates to create tilted ribbons
        vec2 coords = coords_geo.xy - 0.5;
        float cos_a = cos(random_angle);
        float sin_a = sin(random_angle);
        vec2 rotated = vec2(
            coords.x * cos_a - coords.y * sin_a,
            coords.x * sin_a + coords.y * cos_a
        );
        
        // Now work with rotated Y position for ribbon indexing
        float y_pos = rotated.y + 0.5;
        
        // Equal-sized ribbons (20 total)
        float ribbon_count = 20.0;
        float ribbon_index = floor(y_pos * ribbon_count);
        
        // Alternating pattern: even = left, odd = right
        float direction = mod(ribbon_index, 2.0) == 0.0 ? -1.0 : 1.0;
        
        // Cascading delay
        float delay = ribbon_index / ribbon_count * 0.5;
        float ribbon_progress = clamp((progress - delay) / (1.0 - delay), 0.0, 1.0);
        
        // Slide along the rotated X axis
        rotated.x += (1.0 - ribbon_progress) * direction * 2.0;
        
        // Rotate back to get final coordinates
        coords = vec2(
            rotated.x * cos_a + rotated.y * sin_a,
            -rotated.x * sin_a + rotated.y * cos_a
        );
        coords += 0.5;
        
        // Regular sampling
        vec3 coords_tex = niri_geo_to_tex * vec3(coords.x, coords.y, 1.0);
        vec4 color = texture2D(niri_tex, coords_tex.xy);
        
        // Check if ribbon hasn't arrived yet
        if (coords.x < 0.0 || coords.x > 1.0) {
            return vec4(0.0);
        }
        
        return color;
    }
'';
    };
    window-close = {
      custom-shader = ''
    vec4 close_color(vec3 coords_geo, vec3 size_geo) {
        float progress = niri_clamped_progress;
        
        // Completely random angle (0 to 2*PI)
        float random_angle = niri_random_seed * 6.28318;
        
        // Rotate the coordinates to create tilted ribbons
        vec2 coords = coords_geo.xy - 0.5; // center
        float cos_a = cos(random_angle);
        float sin_a = sin(random_angle);
        vec2 rotated = vec2(
            coords.x * cos_a - coords.y * sin_a,
            coords.x * sin_a + coords.y * cos_a
        );
        
        // Now work with rotated Y position for ribbon indexing
        float y_pos = rotated.y + 0.5;
        
        // Equal-sized ribbons (20 total)
        float ribbon_count = 20.0;
        float ribbon_index = floor(y_pos * ribbon_count);
        
        // Alternating pattern: even = left, odd = right
        float direction = mod(ribbon_index, 2.0) == 0.0 ? -1.0 : 1.0;
        
        // Cascading delay
        float delay = ribbon_index / ribbon_count * 0.5;
        float ribbon_progress = clamp((progress - delay) / (1.0 - delay), 0.0, 1.0);
        
        // Slide along the rotated X axis
        rotated.x += ribbon_progress * direction * 2.0;
        
        // Rotate back to get final coordinates
        coords = vec2(
            rotated.x * cos_a + rotated.y * sin_a,
            -rotated.x * sin_a + rotated.y * cos_a
        );
        coords += 0.5; // uncenter
        
        // Regular sampling
        vec3 coords_tex = niri_geo_to_tex * vec3(coords.x, coords.y, 1.0);
        vec4 color = texture2D(niri_tex, coords_tex.xy);
        
        // Check if ribbon has moved out of bounds
        if (coords.x < 0.0 || coords.x > 1.0) {
            return vec4(0.0);
        }
        
        return color;
    }
'';
    };
    horizontal-view-movement = {
      spring = {
        damping-ratio = 0.85;
        stiffness = 423;
        epsilon = 0.0001;
      };
    };
    window-movement = {
      spring = {
        damping-ratio = 0.75;
        stiffness = 323;
        epsilon = 0.0001;
      };
    };
    window-resize = {
      custom-shader = ''
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
                vec3 coords_tex_next = niri_geo_to_tex_next * coords_curr_geo;
                vec4 color = texture2D(niri_tex_next, coords_tex_next.st);
                return color;
            }
'';
    };
    config-notification-open-close = {
      spring = {
        damping-ratio = 0.65;
        stiffness = 923;
        epsilon = 0.001;
      };
    };
    screenshot-ui-open = {
      duration-ms = 200;
    };
    overview-open-close = {
      spring = {
        damping-ratio = 0.85;
        stiffness = 800;
        epsilon = 0.0001;
      };
    };
  };
  roll-drop = {
    workspace-switch = {
      spring = {
        damping-ratio = 0.80;
        stiffness = 523;
        epsilon = 0.0001;
      };
    };
    window-open = {
      custom-shader = ''
vec4 fall_from_top(vec3 coords_geo, vec3 size_geo) {
            float progress = niri_clamped_progress * niri_clamped_progress;
            vec2 coords = (coords_geo.xy - vec2(0.5, 0.0)) * size_geo.xy;
            coords.y += (1.0 - progress) * 1440.0;
            float max_angle = mix(-0.5, 0.5, floor(niri_random_seed * 4.0) / 3.0);
            float angle = (1.0 - progress) * max_angle;
            mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
            coords = rotate * coords;
            coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 0.0), 1.0);
            vec3 coords_tex = niri_geo_to_tex * coords_geo;
            return texture2D(niri_tex, coords_tex.st);
        }
        vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            return fall_from_top(coords_geo, size_geo);
        }
'';
    };
    window-close = {
      custom-shader = ''
vec4 fall_to_bottom(vec3 coords_geo, vec3 size_geo) {
            float progress = niri_clamped_progress * niri_clamped_progress;
            vec2 coords = (coords_geo.xy - vec2(0.5, 0.0)) * size_geo.xy;
            coords.y -= progress * 1440.0;
            float max_angle = mix(-0.5, 0.5, floor(niri_random_seed * 4.0) / 3.0);
            float angle = progress * max_angle;
            mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
            coords = rotate * coords;
            coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 0.0), 1.0);
            vec3 coords_tex = niri_geo_to_tex * coords_geo;
            return texture2D(niri_tex, coords_tex.st);
        }
        vec4 close_color(vec3 coords_geo, vec3 size_geo) {
            return fall_to_bottom(coords_geo, size_geo);
        }
'';
    };
  };
  smoke = {
    window-open = {
      custom-shader = ''
        float hash(vec2 p) {
            return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
        }

        float noise(vec2 p) {
            vec2 i = floor(p);
            vec2 f = fract(p);
            f = f * f * (3.0 - 2.0 * f);
            float a = hash(i);
            float b = hash(i + vec2(1.0, 0.0));
            float c = hash(i + vec2(0.0, 1.0));
            float d = hash(i + vec2(1.0, 1.0));
            return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
        }

        float fbm(vec2 p) {
            float v = 0.0;
            float amp = 0.5;
            for (int i = 0; i < 6; i++) {
                v += amp * noise(p);
                p *= 2.0;
                amp *= 0.5;
            }
            return v;
        }

        float warpedFbm(vec2 p, float t) {
            vec2 q = vec2(fbm(p + vec2(0.0, 0.0)),
                            fbm(p + vec2(5.2, 1.3)));

            vec2 r = vec2(fbm(p + 6.0 * q + vec2(1.7, 9.2) + 0.25 * t),
                            fbm(p + 6.0 * q + vec2(8.3, 2.8) + 0.22 * t));

            vec2 s = vec2(fbm(p + 5.0 * r + vec2(3.1, 7.4) + 0.18 * t),
                            fbm(p + 5.0 * r + vec2(6.7, 0.9) + 0.2 * t));

            return fbm(p + 6.0 * s);
        }

        vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            float p = niri_clamped_progress;
            vec2 uv = coords_geo.xy;
            float seed = niri_random_seed * 100.0;

            float t = p * 12.0 + seed;

            float fluid = warpedFbm(uv * 2.0 + seed, t);

            vec2 center = uv - 0.5;
            float dist = length(center * vec2(1.0, 0.7));

            float appear = (1.0 - dist * 1.2) + (1.0 - fluid) * 0.7;
            float reveal = smoothstep(appear + 0.5, appear - 0.5, (1.0 - p) * 1.8);

            float distort_strength = (1.0 - p) * (1.0 - p) * 0.35;
            vec2 wq = vec2(fbm(uv * 2.0 + vec2(0.0, t * 0.2)),
                            fbm(uv * 2.0 + vec2(5.2, t * 0.2)));
            vec2 wr = vec2(fbm(uv * 2.0 + 4.0 * wq + vec2(1.7, 9.2)),
                            fbm(uv * 2.0 + 4.0 * wq + vec2(8.3, 2.8)));
            vec2 warped_uv = uv + (wr - 0.5) * distort_strength;

            vec3 tex_coords = niri_geo_to_tex * vec3(warped_uv, 1.0);
            vec4 color = texture2D(niri_tex, tex_coords.st);

            return color * reveal;
        }
'';
    };
    window-close = {
      custom-shader = ''
        float hash(vec2 p) {
            return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
        }

        float noise(vec2 p) {
            vec2 i = floor(p);
            vec2 f = fract(p);
            f = f * f * (3.0 - 2.0 * f);
            float a = hash(i);
            float b = hash(i + vec2(1.0, 0.0));
            float c = hash(i + vec2(0.0, 1.0));
            float d = hash(i + vec2(1.0, 1.0));
            return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
        }

        float fbm(vec2 p) {
            float v = 0.0;
            float amp = 0.5;
            for (int i = 0; i < 6; i++) {
                v += amp * noise(p);
                p *= 2.0;
                amp *= 0.5;
            }
            return v;
        }

        float warpedFbm(vec2 p, float t) {
            vec2 q = vec2(fbm(p + vec2(0.0, 0.0)),
                            fbm(p + vec2(5.2, 1.3)));

            vec2 r = vec2(fbm(p + 6.0 * q + vec2(1.7, 9.2) + 0.25 * t),
                            fbm(p + 6.0 * q + vec2(8.3, 2.8) + 0.22 * t));

            vec2 s = vec2(fbm(p + 5.0 * r + vec2(3.1, 7.4) + 0.18 * t),
                            fbm(p + 5.0 * r + vec2(6.7, 0.9) + 0.2 * t));

            return fbm(p + 6.0 * s);
        }

        vec4 close_color(vec3 coords_geo, vec3 size_geo) {
            float p = niri_clamped_progress;
            vec2 uv = coords_geo.xy;
            float seed = niri_random_seed * 100.0;

            float t = p * 12.0 + seed;

            float fluid = warpedFbm(uv * 2.0 + seed, t);

            vec2 center = uv - 0.5;
            float dist = length(center * vec2(1.0, 0.7));

            float dissolve = (1.0 - dist) * 1.2 + fluid * 0.7;
            float remain = smoothstep(dissolve + 0.5, dissolve - 0.5, p * 1.8);

            float distort_strength = p * p * 0.4;
            vec2 wq = vec2(fbm(uv * 2.0 + vec2(0.0, t * 0.2)),
                            fbm(uv * 2.0 + vec2(5.2, t * 0.2)));
            vec2 wr = vec2(fbm(uv * 2.0 + 4.0 * wq + vec2(1.7, 9.2)),
                            fbm(uv * 2.0 + 4.0 * wq + vec2(8.3, 2.8)));
            vec2 warped_uv = uv + (wr - 0.5) * distort_strength;

            vec3 tex_coords = niri_geo_to_tex * vec3(warped_uv, 1.0);
            vec4 color = texture2D(niri_tex, tex_coords.st);

            float tail = smoothstep(1.0, 0.8, p);
            return color * remain * tail;
        }
'';
    };
    window-resize = {
      custom-shader = ''
        float hash(vec2 p) {
            return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
        }

        //generates a random number, based one a vec2
        float noise(vec2 p) {
            vec2 i = floor(p);
            vec2 f = fract(p);
            f = f * f * (3.0 - 2.0 * f);
            float a = hash(i);
            float b = hash(i + vec2(1.0, 0.0));
            float c = hash(i + vec2(0.0, 1.0));
            float d = hash(i + vec2(1.0, 1.0));
            return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
        }

        float fbm(vec2 p) {
            float v = 0.0;
            float amp = 0.5;
            for (int i = 0; i < 6; i++) {
                v += amp * noise(p);
                p *= 2.0;
                amp *= 0.5;
            }
            return v;
        }

        float warpedFbm(vec2 p, float t) {
            vec2 q = vec2(fbm(p + vec2(0.0, 0.0)),
                            fbm(p + vec2(5.2, 1.3)));

            vec2 r = vec2(fbm(p + 6.0 * q + vec2(1.7, 9.2) + 0.25 * t),
                            fbm(p + 6.0 * q + vec2(8.3, 2.8) + 0.22 * t));

            vec2 s = vec2(fbm(p + 5.0 * r + vec2(3.1, 7.4) + 0.18 * t),
                            fbm(p + 5.0 * r + vec2(6.7, 0.9) + 0.2 * t));

            return fbm(p + 6.0 * s);
        }

        vec4 resize_color(vec3 coords_geo, vec3 size_geo) {


            float p = niri_clamped_progress ;
            vec2 uv = coords_geo.xy;
            float seed = noise(uv) ;

            float t = p * 12.0 + seed;

            float fluid = warpedFbm(uv * 2.0 + seed, t);

            vec2 center = uv - 0.5;
            float dist = length(center * vec2(1.0, 0.7));

            float appear = (1.0 - dist * 1.2) + (1.0 - fluid) * 0.7;
            float reveal = smoothstep(appear + 0.5, appear - 0.5, (1.0 - p) * 1.8);

            vec4 color = texture2D(niri_tex_next, coords_geo.st );
            return color * (1.0 - sin(reveal*3.14));
            //              ^ this will curve from one to zero and back up onw
            
        }
'';
    };
  };
  tv_crt = {
    slowdown = 1.0;
    window-open = {
      custom-shader = ''
// =========================
// Exponential
// =========================
float easeInExpo(float t) {
    return t == 0.0 ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}

float easeOutExpo(float t) {
    return t == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
}

float easeInOutExpo(float t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    return t < 0.5
        ? 0.5 * pow(2.0, 20.0 * t - 10.0)
        : 1.0 - 0.5 * pow(2.0, -20.0 * t + 10.0);
}

// =========================
// Sine
// =========================
float easeInSine(float t) {
    return 1.0 - cos((t * 3.141592653589793) / 2.0);
}

float easeOutSine(float t) {
    return sin((t * 3.141592653589793) / 2.0);
}

float easeInOutSine(float t) {
    return -0.5 * (cos(3.141592653589793 * t) - 1.0);
}

// =========================
// Quadratic
// =========================
float easeInQuad(float t) {
    return t * t;
}

float easeOutQuad(float t) {
    return 1.0 - (1.0 - t) * (1.0 - t);
}

float easeInOutQuad(float t) {
    return t < 0.5
        ? 2.0 * t * t
        : 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0;
}

// =========================
// Cubic
// =========================
float easeInCubic(float t) {
    return t * t * t;
}

float easeOutCubic(float t) {
    float f = t - 1.0;
    return f * f * f + 1.0;
}

float easeInOutCubic(float t) {
    return t < 0.5
        ? 4.0 * t * t * t
        : 1.0 - pow(-2.0 * t + 2.0, 3.0) / 2.0;
}

//---

float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

vec2 scaleUV(vec2 uv, vec2 scale) {
    return (uv - 0.5) / scale + 0.5;
}

float centerGradient(float x) {
    x = x * 2.0;
    return x < 1.0 ? x : 2.0 - x;
}

vec4 open_color(vec3 coords_geo, vec3 size_geo) {
    vec2 uv = coords_geo.xy;

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return vec4(0.0);
    }

    float t = easeOutQuad(niri_clamped_progress);

    float x = mix(0.1,1.0,easeOutCubic(niri_clamped_progress));
    float y = easeInQuad(niri_clamped_progress);

    vec2 suv = scaleUV(uv, vec2(x, y));

    if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) {
        return vec4(0.0);
    }

    // Soft edge masks inspired by the BMW shader's center gradients.
    float tb = centerGradient(suv.y);
    float lr = centerGradient(suv.x);

    float tbMask = smoothstep(0.0, 0.10, tb);
    float lrMask = smoothstep(0.0, 0.10, lr);

    float mask = tbMask * lrMask;

    // Cool startup tint.
    vec3 tint = vec3(0.55, 0.82, 1.0);
    vec3 color = mix(tint, vec3(1.0), t);

    // Stronger tint at the beginning.
    float tintAmt = smoothstep(0.0, 0.8, t);

    vec3 rgb = mix(tint, color, tintAmt);
    float alpha = mask * t;

    //gets the window color
    vec4 wColor = texture2D(niri_tex, suv) ; 
    
    //returns the final color
    return mix(vec4(rgb, alpha * wColor.a),wColor, easeInExpo( niri_clamped_progress));

}
'';
    };
    window-close = {
      custom-shader = ''
// =========================
// Exponential
// =========================
float easeInExpo(float t) {
    return t == 0.0 ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}

float easeOutExpo(float t) {
    return t == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
}

float easeInOutExpo(float t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    return t < 0.5
        ? 0.5 * pow(2.0, 20.0 * t - 10.0)
        : 1.0 - 0.5 * pow(2.0, -20.0 * t + 10.0);
}

// =========================
// Sine
// =========================
float easeInSine(float t) {
    return 1.0 - cos((t * 3.141592653589793) / 2.0);
}

float easeOutSine(float t) {
    return sin((t * 3.141592653589793) / 2.0);
}

float easeInOutSine(float t) {
    return -0.5 * (cos(3.141592653589793 * t) - 1.0);
}

// =========================
// Quadratic
// =========================
float easeInQuad(float t) {
    return t * t;
}

float easeOutQuad(float t) {
    return 1.0 - (1.0 - t) * (1.0 - t);
}

float easeInOutQuad(float t) {
    return t < 0.5
        ? 2.0 * t * t
        : 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0;
}

// =========================
// Cubic
// =========================
float easeInCubic(float t) {
    return t * t * t;
}

float easeOutCubic(float t) {
    float f = t - 1.0;
    return f * f * f + 1.0;
}

float easeInOutCubic(float t) {
    return t < 0.5
        ? 4.0 * t * t * t
        : 1.0 - pow(-2.0 * t + 2.0, 3.0) / 2.0;
}

//---

float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

vec2 scaleUV(vec2 uv, vec2 scale) {
    return (uv - 0.5) / scale + 0.5;
}

float centerGradient(float x) {
    x = x * 2.0;
    return x < 1.0 ? x : 2.0 - x;
}

vec4 close_color(vec3 coords_geo, vec3 size_geo) {
    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
        coords_geo.y < 0.0 || coords_geo.y > 1.0) {
        return vec4(0.0);
    }

    vec2 uv = coords_geo.xy;

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return vec4(0.0);
    }

    float t = easeOutQuad(1.0 - niri_clamped_progress);

    float x = mix(0.1,1.0,easeOutCubic(1.0 - niri_clamped_progress));
    float y = easeInQuad(1.0 - niri_clamped_progress);

    vec2 suv = scaleUV(uv, vec2(x, y));

    if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) {
        return vec4(0.0);
    }

    // Soft edge masks inspired by the BMW shader's center gradients.
    float tb = centerGradient(suv.y);
    float lr = centerGradient(suv.x);

    float tbMask = smoothstep(0.0, 0.10, tb);
    float lrMask = smoothstep(0.0, 0.10, lr);

    float mask = tbMask * lrMask;

    // Cool startup tint.
    vec3 tint = vec3(0.55, 0.82, 1.0);
    vec3 color = mix(tint, vec3(1.0), t);

    // Stronger tint at the beginning.
    float tintAmt = smoothstep(0.0, 0.8, t);

    vec3 rgb = mix(tint, color, tintAmt);
    float alpha = mask * t;

    //gets the window color
    vec4 wColor = texture2D(niri_tex, suv) ; 
    
    //returns the final color
    return mix(vec4(rgb, alpha * wColor.a),wColor, easeInExpo( 1.0 - niri_clamped_progress));
}
'';
    };
    window-resize = {
      custom-shader = ''
const float PI = 3.141592653589793;

float hash21(vec2 p) {
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float noise2(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
        + (c - a) * u.y * (1.0 - u.x)
        + (d - b) * u.x * u.y;
}

vec3 randomRGB(vec2 uv, float t) {
    // Independent noise per channel → real CRT chaos
    float r = noise2(uv * 1.3 + vec2(13.0, 71.0) + t * 120.0);
    float g = noise2(uv * 1.7 + vec2(37.0, 19.0) + t * 90.0);
    float b = noise2(uv * 1.1 + vec2(91.0, 53.0) + t * 140.0);
    return vec3(r, g, b);
}

vec4 resize_color(vec3 coords_geo, vec3 size_geo) {
    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
        coords_geo.y < 0.0 || coords_geo.y > 1.0) {
        return vec4(0.0);
    }

    vec2 uv = coords_geo.xy;
    float t = niri_clamped_progress;

    // Strongest mid-animation
    float pulse = sin(t * PI);

    // Multi-scale noise layers (coarse + fine)
    vec2 base = uv * size_geo.xy;

    vec3 coarse = randomRGB(floor(base * 0.12), t);
    vec3 mid    = randomRGB(base * 0.35, t);
    vec3 fine   = randomRGB(base * 0.9,  t);

    // Combine for richer randomness
    vec3 snow = mix(coarse, mid, 0.5);
    snow = mix(snow, fine, 0.35);

    // Center around 0
    snow -= 0.5;

    // Add subtle horizontal interference streaks
    float streak = sin(uv.y * size_geo.y * 0.6 + t * 80.0) * 0.15;
    snow += vec3(streak);

    // Slight color bias flicker
    vec3 tint = vec3(
        sin(t * 37.0) * 0.2,
        sin(t * 53.0) * 0.2,
        sin(t * 29.0) * 0.2
    );

    snow += tint;

    // Final intensity
    float strength = 0.55;
    vec4 color = vec4(snow,1.0) * strength * pulse;
    color.a = 1.0;

    float alpha = length(color) * 1.2;

    vec4 wColor = texture2D(niri_tex_next, (coords_geo * niri_geo_to_tex_next).st );

    return mix(wColor, color, pulse * 0.5);

}
'';
    };
  };
}
