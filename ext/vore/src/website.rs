use std::{borrow::BorrowMut, cell::RefCell};

use magnus::{function, prelude::*, scan_args, Error, RHash, RModule, Ruby, Value};

#[derive(Clone)]
pub struct Website {
    website: String,
}

#[derive(Clone)]
#[magnus::wrap(class = "Vore::Sanitizer")]
pub struct VoreWebsite(RefCell<Website>);

impl VoreWebsite {
    pub fn new(arguments: &[Value]) -> Result<Self, magnus::Error> {
        let args = scan_args::scan_args::<(String,), (), (), (), (), ()>(arguments)?;
        let (website,): (String,) = args.required;

        Ok(Self(RefCell::new(Website { website: website })))
    }

    // pub async fn scrape(&self) -> Result<(), magnus::Error> {
    //     let mut binding = self.0.borrow_mut();

    //     binding.website.scrape().await;

    //     Ok(())
    // }
}

pub fn init(m_vore: RModule) -> Result<(), magnus::Error> {
    let c_website = m_vore
        .define_class("Website", magnus::class::object())
        .expect("cannot define class Vore::Website");

    c_website.define_singleton_method("new", function!(VoreWebsite::new, -1))?;
    // c_website.define_method("scrape!", function!(VoreWebsite::scrape, 1))?;

    Ok(())
}
