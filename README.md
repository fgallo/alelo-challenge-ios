# Alelo iOS Challenge App Case

## Product List Feature Specs

### Story: Customer requests to see a product list

### Narrative #1

```
As an online customer
I want the app to automatically load a list of products
So I can see product's image, name, price, sale price (if available) and sizes
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see the list of products
 Then the app should display the list of products
```

## Use Cases

### Load Products From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Products" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates products from valid data.
5. System delivers products.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---

## Model Specs

### Product

| Property      | Type          |
|---------------|---------------|
| `name`        | `String`      |
| `regularPrice`| `String`      |
| `salePrice`   | `String`      |
| `onSale`      | `Bool`        |
| `imageURL`    | `URL`         |
| `sizes`       | `[Size]`      |

### Size

| Property      | Type          |
|---------------|---------------|
| `size`        | `String`      |
| `sku`         | `String`      |
| `available`   | `Bool`        |

### Payload contract

```
GET /products

200 RESPONSE

{
	"products": [
        {
            "name": "VESTIDO TRANSPASSE BOW",
            "style": "20002605",
            "code_color": "20002605_613",
            "color_slug": "tapecaria",
            "color": "TAPEÇARIA",
            "on_sale": false,
            "regular_price": "R$ 199,90",
            "actual_price": "R$ 199,90",
            "discount_percentage": "",
            "installments": "3x R$ 66,63",
            "image": "https://d3l7rqep7l31az.cloudfront.net/images/products/20002605_615_catalog_1.jpg?1460136912",
            "sizes": [{
                "available": false,
                "size": "PP",
                "sku": "5807_343_0_PP"
            }, {
                "available": true,
                "size": "P",
                "sku": "5807_343_0_P"
            }, {
                "available": true,
                "size": "M",
                "sku": "5807_343_0_M"
            }, {
                "available": true,
                "size": "G",
                "sku": "5807_343_0_G"
            }, {
                "available": false,
                "size": "GG",
                "sku": "5807_343_0_GG"
            }]
        },
        {
            "name": "T-SHIRT LEATHER DULL",
            "style": "20002602",
            "code_color": "20002602_027",
            "color_slug": "marinho",
            "color": "MARINHO",
            "on_sale": true,
            "regular_price": "R$ 139,90",
            "actual_price": "R$ 119,90",
            "discount_percentage": "12%",
            "installments": "3x R$ 39,97",
            "image": "",
            "sizes": [{
                "available": true,
                "size": "PP",
                "sku": "5793_1000032_0_PP"
            }, {
                "available": true,
                "size": "P",
                "sku": "5793_1000032_0_P"
            }, {
                "available": true,
                "size": "M",
                "sku": "5793_1000032_0_M"
            }, {
                "available": false,
                "size": "G",
                "sku": "5793_1000032_0_G"
            }, {
                "available": false,
                "size": "GG",
                "sku": "5793_1000032_0_GG"
            }]
        },
        {
            "name": "ÓCULOS DE SOL AVIADOR VINTAGE",
            "style": "20001883",
            "code_color": "20001883_019",
            "color_slug": "cinza",
            "color": "CINZA",
            "on_sale": true,
            "regular_price": "R$ 109,90",
            "actual_price": "R$ 49,90",
            "discount_percentage": "55%",
            "installments": "1x R$ 49,90",
            "image": "https://d3l7rqep7l31az.cloudfront.net/images/products/20001883_019_catalog_1.jpg?",
            "sizes": [{
                "available": true,
                "size": "U",
                "sku": "4231_1000038_0_U"
            }]
	    }
		...
	]
}
```