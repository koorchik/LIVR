// Examples of the playground, grouped in its "Example" menu. Rules, data and aliases are JSON5.
export interface Preset {
  group: 'LIVR 2.0' | 'LIVR 2.5' | 'Aliases'
  name: string
  rules: string
  data: string
  aliases?: string
}

export const PRESETS: Preset[] = [
  {
    group: 'LIVR 2.0',
    name: 'Registration form',
    rules: `{
    name: 'required',
    email: ['required', 'email'],
    gender: { one_of: ['male', 'female'] },
    phone: { max_length: 10 },
    password: ['required', { min_length: 10 }],
    password2: { equal_to_field: 'password' }
}`,
    data: `{
    name: 'John',
    email: 'john@mail.com',
    gender: 'male',
    phone: '+22221212',
    password: 'mypassword1',
    password2: 'mypassword1'
}`
  },
  {
    group: 'LIVR 2.0',
    name: 'Nested object',
    rules: `{
    name: 'required',
    phone: { max_length: 10 },
    address: { nested_object: {
        city: 'required',
        zip: ['required', 'positive_integer']
    }}
}`,
    data: `{
    name: 'Michael',
    phone: '0441234567',
    address: {
        city: 'Kyiv',
        zip: '30552'
    }
}`
  },
  {
    group: 'LIVR 2.0',
    name: 'List of values',
    rules: `{
    order_id: ['required', 'positive_integer'],
    product_ids: { list_of: ['required', 'positive_integer'] }
}`,
    data: `{
    order_id: 10455,
    product_ids: [3455, 3456, 3566]
}`
  },
  {
    group: 'LIVR 2.0',
    name: 'List of objects',
    rules: `{
    order_id: ['required', 'positive_integer'],
    products: ['not_empty_list', { list_of_objects: {
        product_id: ['required', 'positive_integer'],
        quantity: ['required', 'positive_integer']
    }}]
}`,
    data: `{
    order_id: 10345,
    products: [
        { product_id: 3455, quantity: 2 },
        { product_id: 3456, quantity: 0 }
    ]
}`
  },
  {
    group: 'LIVR 2.0',
    name: 'List of different objects',
    rules: `{
    order_id: ['required', 'positive_integer'],
    products: ['required', { list_of_different_objects: [
        'product_type', {
            material: {
                product_type: 'required',
                material_id: ['required', 'positive_integer'],
                quantity: ['required', { min_number: 1 }],
                warehouse_id: 'positive_integer'
            },
            service: {
                product_type: 'required',
                name: ['required', { max_length: 20 }]
            }
        }
    ]}]
}`,
    data: `{
    order_id: 10455,
    products: [{
        product_type: 'material',
        material_id: 345,
        quantity: 5,
        warehouse_id: 24
    }, {
        product_type: 'service',
        name: 'Clean filter'
    }]
}`
  },
  {
    group: 'LIVR 2.0',
    name: 'Modifiers',
    rules: `{
    email: ['trim', 'required', 'email', 'to_lc'],
    country: ['trim', 'to_uc', { length_equal: 2 }],
    newsletter: { default: 'no' }
}`,
    data: `{
    email: '  John.Smith@Example.COM ',
    country: ' ua',
    unknown_field: 'is removed from the output'
}`
  },
  {
    group: 'Aliases',
    name: 'Rules aliasing',
    aliases: `[{
    name: 'adult_age',
    rules: ['positive_integer', { min_number: 18 }],
    error: 'WRONG_AGE'
}]`,
    rules: `{
    name: 'required',
    age: ['required', 'adult_age']
}`,
    data: `{
    name: 'Viktor',
    age: 16
}`
  },
  {
    group: 'LIVR 2.5',
    name: 'LIVR 2.5 rules',
    rules: `{
    id: ['required', 'uuid'],
    ip: { ip: 'v4' },
    subscribe: ['required', 'boolean'],
    email: [{ required_if: { subscribe: true } }, 'email'],
    tags: ['unique', { list_length: [1, 3] }],
    birth_date: { iso_date: { max: 'today' } }
}`,
    data: `{
    id: '0b9f4c2e-6a1d-4f3b-9e2a-7c5d8e1f2a3b',
    ip: '192.168.1.300',
    subscribe: true,
    email: '',
    tags: ['livr', 'validation', 'livr'],
    birth_date: '1990-05-17'
}`
  },
  {
    group: 'LIVR 2.5',
    name: 'Checkout: when, uuid, iban, unique',
    rules: `{
    order_id: ['required', {uuid: 'v4'}],
    delivery_date: ['required', {iso_date: {min: 'tomorrow'}}],
    payment_method: ['required', {one_of: ['card', 'bank']}],
    payment: ['required', {when: ['payment_method', {
        card: {nested_object: {number: ['required', 'credit_card']}},
        bank: {nested_object: {iban: ['required', 'iban']}}
    }]}],
    company: 'string',
    vat_number: {when: ['company', 'not_empty', 'required']},
    items: ['required', {list_length: {min: 1}}, {unique: 'sku'}, {list_of_objects: {
        sku: ['required', {starts_with: 'SKU-'}],
        quantity: ['required', 'positive_integer']
    }}],
    newsletter: 'boolean'
}`,
    data: `{
    order_id: '0b9f4c2e-6a1d-4f3b-9e2a-7c5d8e1f2a3b',
    delivery_date: '2099-05-17',
    payment_method: 'bank',
    payment: {iban: 'DE89370400440532013000'},
    company: 'Acme GmbH',
    vat_number: 'DE123456789',
    items: [
        {sku: 'SKU-1001', quantity: 2},
        {sku: 'SKU-2002', quantity: 1}
    ],
    newsletter: 'true'
}`
  },
  {
    group: 'LIVR 2.5',
    name: 'Query filters: split, ip, keys, values',
    rules: `{
    ids: [{split: ','}, {list_length: [1, 20]}, 'unique', {list_of: {uuid: 'v7'}}],
    status: {split: ','},
    min_price: ['decimal', {max_decimals: 2}],
    created_from: 'iso_datetime',
    client_ip: 'ip',
    labels: [{keys: {like: '^[a-z_]+$'}}, {values: ['string', {max_length: 30}]}]
}`,
    data: `{
    ids: '019a5f6e-7c1d-7b3e-9f20-1a2b3c4d5e6f,019a5f6e-7c1d-7b3e-9f20-1a2b3c4d5e70',
    status: 'paid,shipped',
    min_price: '10.50',
    created_from: '2026-11-01T00:00:00+02:00',
    client_ip: '2001:db8::1',
    labels: {team: 'billing', region: 'eu-west'}
}`
  },
  {
    group: 'Aliases',
    name: 'User registration',
    aliases: `[
    {
        name: 'user_email',
        rules: 'email',
        error: 'INVALID_USER_EMAIL'
    },
    {
        name: 'secure_password',
        rules: [{min_length: 8}, {max_length: 64}],
        error: 'PASSWORD_TOO_WEAK'
    },
    {
        name: 'account_name',
        rules: [{min_length: 3}, {max_length: 20}, {like: '^[a-zA-Z0-9_]+$'}],
        error: 'INVALID_ACCOUNT_NAME'
    }
]`,
    rules: `{
    username: ['required', 'account_name'],
    email: ['required', 'user_email'],
    password: ['required', 'secure_password'],
    password_confirm: ['required', {equal_to_field: 'password'}],
    age: ['positive_integer', {min_number: 13}],
    terms_accepted: {eq: true}
}`,
    data: `{
    username: 'john_doe',
    email: 'john@example.com',
    password: 'SecurePass123',
    password_confirm: 'SecurePass123',
    age: 25,
    terms_accepted: true
}`
  },
  {
    group: 'Aliases',
    name: 'E-commerce',
    aliases: `[
    {
        name: 'product_price',
        rules: 'positive_decimal',
        error: 'INVALID_PRODUCT_PRICE'
    },
    {
        name: 'catalog_sku',
        rules: {like: '^[A-Z]{2,4}-[0-9]{4,8}$'},
        error: 'INVALID_CATALOG_SKU'
    },
    {
        name: 'order_quantity',
        rules: ['positive_integer', {max_number: 9999}],
        error: 'QUANTITY_OUT_OF_RANGE'
    },
    {
        name: 'discount_info',
        rules: {nested_object: {
            amount: ['required', 'product_price'],
            valid_until: ['required', 'iso_date']
        }}
    }
]`,
    rules: `{
    sku: ['required', 'catalog_sku'],
    name: ['required', {max_length: 100}],
    price: ['required', 'product_price'],
    quantity: ['required', 'order_quantity'],
    discount: 'discount_info'
}`,
    data: `{
    sku: 'PRD-12345',
    name: 'Wireless Bluetooth Headphones',
    price: 79.99,
    quantity: 150,
    discount: {
        amount: 59.99,
        valid_until: '2025-12-31'
    }
}`
  }
]
