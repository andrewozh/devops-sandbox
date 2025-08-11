import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';
import React, { useState, useEffect } from 'react';

import styles from './index.module.css';

function HomepageHeader() {
  const [currentRole, setCurrentRole] = useState(0);
  const roles = ['DevOps', 'Cloud', 'Platform'];

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentRole((prev) => (prev + 1) % roles.length);
    }, 2000); // Change every 2 seconds

    return () => clearInterval(interval);
  }, [roles.length]);

  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className={styles.heroContent}>
        <div className={styles.heroText}>
          <h1 className={styles.heroTitle}>
            Hi, I'm Andrew Ozhegov
          </h1>
          <div className={styles.roleContainer}>
            <div className={styles.roleCarousel}>
              <span className={styles.roleText}>{roles[currentRole]}</span>
            </div>
            <span className={styles.engineerText}>Engineer</span>
          </div>
        </div>
        <div className={styles.heroDescription}>
          <p className={styles.descriptionText}>
            My goal here, is to combine the most useful devops practices and tools into a single project, 
            that can be used as a demo for my skills and as a sandbox for learning new tools and practices.
          </p>
        </div>
        <div className={styles.heroButtons}>
          <Link
            className={clsx('button button--primary button--lg', styles.cvButton)}
            to="/cv">
            Check out my CV
          </Link>
          <Link
            className={clsx('button button--primary button--lg', styles.sandboxButton)}
            to="/docs/">
            Demo project
          </Link>
          <Link
            className={clsx('button button--secondary button--lg', styles.emailButton)}
            href="mailto:andrewozhegov@gmail.com">
            Email Me
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description="Description will go into a meta tag in <head />">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
