{
  window-open = {
    custom-shader = ''
        // functions - if needed
        // Scale UV around a pivot
        vec2 scaleUV(vec2 uv, vec2 pivot, vec2 scale) {
            return (uv - pivot) / scale + pivot;
        }

        vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
                coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                return vec4(0.0);
            }

            // variables - if needed
            float progress = niri_clamped_progress;

            // code
            float scale = 1.0;
            if (progress <= 0.1) {
                scale = 0.25;
            } else if (progress <= 0.2) {
                scale = 0.5;
            } else if (progress <= 0.3) {
                scale = 0.25;
            } else if (progress <= 0.4) {
                scale = 0.5;
            } else if (progress <= 0.5) {
                scale = 0.25;
            } else if (progress <= 0.6) {
                scale = 0.5;
            } else if (progress <= 0.7) {
                scale = 1.0;
            } else if (progress <= 0.8) {
                scale = 0.25;
            } else if (progress <= 0.9) {
                scale = 0.5;
            }

            vec2 uv = scaleUV(coords_geo.xy, vec2(0.5), vec2(scale));

            //return color 
            return texture2D(niri_tex, uv);
        }
'';
  };
  window-close = {
    custom-shader = ''
        // functions - if needed
        // Scale UV around a pivot
        vec2 scaleUV(vec2 uv, vec2 pivot, vec2 scale) {
            return (uv - pivot) / scale + pivot;
        }


        vec4 close_color(vec3 coords_geo, vec3 size_geo) {
            if (coords_geo.x < 0.0 || coords_geo.x > 1.0 ||
                coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                return vec4(0.0);
            }

            // variables - if needed
            float progress = niri_clamped_progress;

            // code
            float scale = 1.0;
            if (progress <= 0.1) {
                scale = 0.25;
            } else if (progress <= 0.2) {
                scale = 0.5;
            } else if (progress <= 0.3) {
                scale = 0.25;
            } else if (progress <= 0.4) {
                scale = 0.5;
            } else if (progress <= 0.5) {
                scale = 0.25;
            } else if (progress <= 0.6) {
                scale = 0.5;
            } else if (progress <= 0.7) {
                scale = 1.0;
            } else if (progress <= 0.8) {
                scale = 0.25;
            } else if (progress <= 0.9) {
                scale = 0.5;
            }

            vec2 uv = scaleUV(coords_geo.xy, vec2(0.5), vec2(scale));

            //return color 
            return texture2D(niri_tex, uv);
        }
'';
  };
}
