# AETHER Design Tokens マスター定義

## 概要

本ドキュメントはAETHERのGenerative UIエンジンで使用するDesign Tokensの詳細仕様を定義します。
Gemini AIはこれらのトークンを生成・調整してアプリ全体のUIを変更します。

---

## トークン構造

```json
{
  "theme_palette": { ... },
  "component_geometry": { ... },
  "typography_preset": { ... },
  "layout_density": { ... },
  "interaction_flow": { ... }
}
```

---

## 1. theme_palette（色設定）

### スキーマ

```json
{
  "theme_palette": {
    "primary": "#6366F1",
    "primary_variant": "#4338CA",
    "secondary": "#F59E0B",
    "secondary_variant": "#D97706",
    "background": "#0F172A",
    "surface": "#1E293B",
    "surface_variant": "#334155",
    "error": "#EF4444",
    "success": "#22C55E",
    "warning": "#F59E0B",
    "on_primary": "#FFFFFF",
    "on_secondary": "#000000",
    "on_background": "#F1F5F9",
    "on_surface": "#E2E8F0",
    "on_error": "#FFFFFF",
    "outline": "#475569",
    "shadow": "#000000"
  }
}
```

### 制約（Constraints）

| プロパティ | 制約 | 理由 |
|------------|------|------|
| `on_*` と `*` のコントラスト比 | ≥ 4.5:1 | WCAG AA準拠 |
| `background` と `surface` の明度差 | ≥ 5% | 視認性確保 |
| 色の彩度 | 20% 〜 90% | 極端な色を防止 |

---

## 2. component_geometry（形状設定）

### スキーマ

```json
{
  "component_geometry": {
    "border_radius": {
      "none": 0,
      "sm": 4,
      "md": 8,
      "lg": 16,
      "xl": 24,
      "full": 9999
    },
    "elevation": {
      "none": 0,
      "sm": 2,
      "md": 4,
      "lg": 8,
      "xl": 16
    },
    "border_width": {
      "none": 0,
      "thin": 1,
      "medium": 2,
      "thick": 4
    },
    "component_defaults": {
      "button": {
        "border_radius": "md",
        "elevation": "sm"
      },
      "card": {
        "border_radius": "lg",
        "elevation": "md"
      },
      "input": {
        "border_radius": "sm",
        "border_width": "thin"
      },
      "fab": {
        "border_radius": "full",
        "elevation": "lg"
      }
    }
  }
}
```

### 制約

| プロパティ | 最小値 | 最大値 | 単位 |
|------------|--------|--------|------|
| `border_radius.*` | 0 | 9999 | dp |
| `elevation.*` | 0 | 24 | dp |
| `border_width.*` | 0 | 8 | dp |

### コンポーネント固有の制限

| コンポーネント | プロパティ | 最小 | 最大 | 理由 |
|----------------|------------|------|------|------|
| BottomSheet | border_radius (top) | 16 | 28 | 極端な角丸でUI崩れを防止 |
| Dialog | border_radius | 8 | 32 | 読みやすさを確保 |

---

## 3. typography_preset（文字設定）

### スキーマ

```json
{
  "typography_preset": {
    "font_family": {
      "primary": "Inter",
      "secondary": "Roboto Mono",
      "display": "Outfit"
    },
    "font_size": {
      "xs": 10,
      "sm": 12,
      "base": 14,
      "lg": 16,
      "xl": 20,
      "2xl": 24,
      "3xl": 32,
      "4xl": 40
    },
    "font_weight": {
      "light": 300,
      "normal": 400,
      "medium": 500,
      "semibold": 600,
      "bold": 700
    },
    "line_height": {
      "tight": 1.2,
      "normal": 1.5,
      "relaxed": 1.75
    },
    "letter_spacing": {
      "tight": -0.5,
      "normal": 0,
      "wide": 0.5,
      "wider": 1.0
    },
    "text_styles": {
      "display_large": {
        "font_family": "display",
        "font_size": "4xl",
        "font_weight": "bold",
        "line_height": "tight"
      },
      "headline": {
        "font_family": "primary",
        "font_size": "2xl",
        "font_weight": "semibold",
        "line_height": "tight"
      },
      "body": {
        "font_family": "primary",
        "font_size": "base",
        "font_weight": "normal",
        "line_height": "normal"
      },
      "caption": {
        "font_family": "primary",
        "font_size": "sm",
        "font_weight": "normal",
        "line_height": "normal"
      },
      "code": {
        "font_family": "secondary",
        "font_size": "sm",
        "font_weight": "normal",
        "line_height": "relaxed"
      }
    }
  }
}
```

### 制約

| プロパティ | 最小値 | 最大値 | 単位 |
|------------|--------|--------|------|
| `font_size.*` | 8 | 64 | sp |
| `line_height.*` | 1.0 | 2.5 | 倍率 |
| `letter_spacing.*` | -1.0 | 2.0 | dp |

---

## 4. layout_density（余白設定）

### スキーマ

```json
{
  "layout_density": {
    "spacing": {
      "none": 0,
      "xs": 4,
      "sm": 8,
      "md": 16,
      "lg": 24,
      "xl": 32,
      "2xl": 48
    },
    "density_mode": "comfortable",
    "density_multiplier": {
      "compact": 0.75,
      "comfortable": 1.0,
      "spacious": 1.25
    },
    "grid": {
      "columns": 4,
      "gutter": 16,
      "margin": 16
    },
    "component_spacing": {
      "card_gap": "md",
      "list_item_padding": "sm",
      "section_gap": "xl",
      "button_padding_h": "lg",
      "button_padding_v": "sm"
    }
  }
}
```

### 制約

| プロパティ | 最小値 | 最大値 | 単位 |
|------------|--------|--------|------|
| `spacing.*` | 0 | 64 | dp |
| `density_multiplier.*` | 0.5 | 2.0 | 倍率 |
| `grid.columns` | 2 | 6 | 個 |

---

## 5. interaction_flow（アニメーション設定）

### スキーマ

```json
{
  "interaction_flow": {
    "duration": {
      "instant": 0,
      "fast": 150,
      "normal": 300,
      "slow": 500,
      "slower": 800
    },
    "easing": {
      "linear": "linear",
      "ease_in": "cubic-bezier(0.4, 0, 1, 1)",
      "ease_out": "cubic-bezier(0, 0, 0.2, 1)",
      "ease_in_out": "cubic-bezier(0.4, 0, 0.2, 1)",
      "bounce": "cubic-bezier(0.68, -0.55, 0.265, 1.55)"
    },
    "haptic": {
      "enabled": true,
      "intensity": "medium",
      "feedback_types": {
        "tap": "light",
        "success": "medium",
        "error": "heavy",
        "selection": "light"
      }
    },
    "transitions": {
      "page_enter": {
        "duration": "normal",
        "easing": "ease_out",
        "type": "slide_up"
      },
      "page_exit": {
        "duration": "fast",
        "easing": "ease_in",
        "type": "fade"
      },
      "modal_enter": {
        "duration": "normal",
        "easing": "bounce",
        "type": "scale"
      },
      "button_press": {
        "duration": "fast",
        "easing": "ease_out",
        "type": "scale"
      }
    },
    "reduced_motion": false
  }
}
```

### 制約

| プロパティ | 最小値 | 最大値 | 単位 |
|------------|--------|--------|------|
| `duration.*` | 0 | 1000 | ms |
| `haptic.intensity` | - | - | light/medium/heavy |

---

## プリセットテーマ

### 1. Default（デフォルト）

モダンでクリーンなダークテーマ。

```json
{
  "name": "default",
  "theme_palette": {
    "primary": "#6366F1",
    "background": "#0F172A",
    "surface": "#1E293B"
  },
  "component_geometry": {
    "component_defaults": {
      "button": { "border_radius": "md" }
    }
  }
}
```

---

### 2. Cyberpunk（サイバーパンク）

ネオンカラーとシャープなエッジ。

```json
{
  "name": "cyberpunk",
  "theme_palette": {
    "primary": "#00FFFF",
    "secondary": "#FF00FF",
    "background": "#0A0A0A",
    "surface": "#1A1A2E"
  },
  "component_geometry": {
    "component_defaults": {
      "button": { "border_radius": "none" },
      "card": { "border_radius": "sm", "border_width": "thin" }
    }
  },
  "typography_preset": {
    "font_family": { "primary": "Orbitron" }
  }
}
```

---

### 3. Minimal（ミニマル）

ライトテーマ、シンプルな形状。

```json
{
  "name": "minimal",
  "theme_palette": {
    "primary": "#171717",
    "background": "#FAFAFA",
    "surface": "#FFFFFF",
    "on_background": "#171717"
  },
  "component_geometry": {
    "component_defaults": {
      "button": { "border_radius": "full" },
      "card": { "elevation": "none", "border_width": "thin" }
    }
  },
  "layout_density": {
    "density_mode": "spacious"
  }
}
```

---

### 4. Nature（ネイチャー）

アースカラー、オーガニックな形状。

```json
{
  "name": "nature",
  "theme_palette": {
    "primary": "#22C55E",
    "secondary": "#84CC16",
    "background": "#14532D",
    "surface": "#166534"
  },
  "component_geometry": {
    "component_defaults": {
      "button": { "border_radius": "lg" },
      "card": { "border_radius": "xl" }
    }
  }
}
```

---

### 5. Sunset（サンセット）

暖色系グラデーション。

```json
{
  "name": "sunset",
  "theme_palette": {
    "primary": "#F97316",
    "secondary": "#EC4899",
    "background": "#1C1917",
    "surface": "#292524"
  },
  "interaction_flow": {
    "transitions": {
      "page_enter": { "duration": "slow", "easing": "ease_in_out" }
    }
  }
}
```

---

## バリデーションルール

```dart
class DesignTokenValidator {
  static bool validateContrastRatio(String foreground, String background) {
    // WCAG AA: 4.5:1 for normal text, 3:1 for large text
    return calculateContrastRatio(foreground, background) >= 4.5;
  }
  
  static bool validateTokens(Map<String, dynamic> tokens) {
    // すべての必須キーが存在するか確認
    // 値が制約範囲内か確認
    // コントラスト比が基準を満たすか確認
    return true;
  }
}
```
